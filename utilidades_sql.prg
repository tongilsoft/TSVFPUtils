&& Este procedimiento se encarga de preparar el Script de creacion de la base de datos MySQL para
&& el cliente en un archivo en disco con extension sql.
PROCEDURE preparar_script_sql()
	SET TEXTMERGE DELIMITERS TO <<,>>
   	TEXT TO script_sql NOSHOW && --> INICIO SCRIPT SQL
   	
	ENDTEXT && --> FIN SCRIPT SQL
   	SET TEXTMERGE ON TO MEMVAR script_sql NOSHOW
   	SET SAFETY OFF 
   	STRTOFILE(TEXTMERGE(script_sql),archivo_sql)
   	SET SAFETY ON 
   	SET TEXTMERGE TO
   	SET TEXTMERGE OFF
   	RETURN FILE(archivo_sql)
ENDPROC

************************************************************************
* getSqlValue
************************************************************************
* Ejecuta una instruccion SQL en el servidor para obtener un valor escalar
* El objetivo de este procedimiento es efectuar una consulta segura contra fallos
* para evitar que el programador tenga que escribir condigos de validacion adicionales
* resultando en desperdicio de tiempo, por ello es recomendado que las instrucciones SQL
* sean normalizadas con CAST() e IFNULL() para asegurar que el resultado no sea NULL 
* y sea del tipo esperado, a continuacion se presenta un ejemplo para ilustrar la idea.
*
* Ejemplo de uso: 
*   LOCAL cSQL, nTotal
*   cSQL = "SELECT CAST(IFNULL(SUM(importe),0) AS SIGNED) AS total FROM facturacion_det;"
*   nTotal = 0
*   IF getSqlValue(cSQL,"total",0,@nTotal) THEN
*   	&& Seguir el curso normal de ejecucion
*   ELSE
*       && Algun Error con la instruccion SQL o algun problema ocurrio
*       && la instruccion NO se executo correctamente
*   ENDIF 
*
* Parametros:
* -cSQL: string con la instruccion SQL a ser ejecutada 
* -cFieldName: nombre del campo que se debe extraer del cursor resultante de la consulta
* -cDataTypeExpected: tipo de datos esperado para el escalar
* -defaultValue: valor predeterminado para el escalar solicitado
* -sqlValue: variable en la que se almacenara el valor del escalar obtenido
*
* Valores devueltos:
* Devuelve .T. (Verdadero) si la instruccion SQL se ejecuto con exito, 
* de lo contrario devuelve .F. (falso). 
* El valor del escalar solicitado se escribe en sqlValue (cuarto parametro)
* Si no fue posible obtener el escalar en cuestion, sqlValue siempre sera 
* el valor especificado como defaultValue.
************************************************************************
PROCEDURE getSqlValue
	LPARAMETERS cSqlCmd, cFieldName, cDataTypeExpected, defaultValue, sqlValue
	sqlValue = defaultValue
	LOCAL ok, oFldUtils
	oFldUtils=CREATEOBJECT("utilidad_campos")
   	ok=SQLEXEC(conexion, cSqlCmd, "cur_sql_value",aCnt)
   	DO CASE 
   		CASE ok = -1
   			mostrar_error_odbc_ui()
   		CASE ok > 0
   			IF aCnt[1,2] > 0 THEN 
   				SELECT cur_sql_value
   				GOTO TOP 
   				SCATTER MEMO MEMVAR 
   				sqlValue = oFldUtils.fetchFieldValue(m.&cFieldName,cDataTypeExpected,defaultValue)
   				RETURN .t.
   			ENDIF
   	ENDCASE
   	RETURN .f.
ENDPROC 

************************************************************************
* execSql
************************************************************************
* Ejecuta una instruccion SQL en el servidor del cual no se espera obtener un resultado
* Ejemplo de uso: 
*   LOCAL cSQL
*   cSQL = "SET SQL_SAFE_UPDATES = 0;"
*   IF execSql(cSQL) THEN
*   	&& Seguir el curso normal de ejecucion
*		&& la instruccion se executo correctamente
*   ELSE
*       && Algun Error con la instruccion SQL o algun problema ocurrio
*       && la instruccion NO se executo correctamente
*   ENDIF 
*
* Parametros:
* -cSQL: string con la instruccion SQL a ser ejecutada 
*
* Valores devueltos:
* devuelve .T. (Verdadero) si la instruccion SQL se ejecuto con exito, 
* de lo contrario devuelve .F. (falso)
************************************************************************
PROCEDURE execSql
	LPARAMETERS cSqlCmd
	LOCAL ok
   	ok=SQLEXEC(conexion, cSqlCmd, "cur_sql_exec",aCnt)
   	DO CASE 
   		CASE ok = -1
   			mostrar_error_odbc_ui()
   		CASE ok > 0
   			RETURN .t.
   	ENDCASE
   	RETURN .f.
ENDPROC 

************************************************************************
* getSqlCursor
************************************************************************
* Ejecuta una instruccion SQL en el servidor para obtener un cursor con
* los resultador de la consulta.
* El objetivo de este procedimiento es efectuar una consulta segura contra fallos
* para evitar que el programador tenga que escribir condigos de validacion adicionales
* resultando en desperdicio de tiempo, por ello es recomendado que las instrucciones SQL
* sean normalizadas con CAST() e IFNULL() para asegurar que el resultado no sea NULL 
* y sea del tipo esperado, a continuacion se presenta un ejemplo para ilustrar la idea.
*
* Ejemplo de uso: 
*   LOCAL cSQL
*   cSQL = "SELECT CAST(IFNULL(debe,0) AS SIGNED) AS debe,";
*  		 + "CAST(IFNULL(haber,0) AS SIGNED) AS haber";
*   	 + " FROM facturacion_det;"
*   IF getSqlCursor(cSQL,"facturacion_det") THEN
*   	&& Seguir el curso normal de ejecucion
*   ELSE
*       && Algun Error con la instruccion SQL o algun problema ocurrio
*       && la instruccion NO se executo correctamente
*   ENDIF 
*
* Parametros:
* - cSQL: string con la instruccion SQL a ser ejecutada 
* - cCursorName: nombre del cursor que almacenara el resultado de la consulta
*
* Valores devueltos:
* Devuelve .T. (Verdadero) si la instruccion SQL se ejecuto con exito, 
* de lo contrario devuelve .F. (falso). 
************************************************************************
PROCEDURE getSqlCursor
	LPARAMETERS cSqlCmd, cCursorName

	LOCAL ok
   	ok=SQLEXEC(conexion, cSqlCmd, cCursorName, aCnt)
   	DO CASE 
   		CASE ok = -1
   			mostrar_error_odbc_ui()
   		CASE ok > 0
   			IF aCnt[1,2] > 0 THEN 
   				RETURN .t.
   			ENDIF
   	ENDCASE
   	RETURN .f.
ENDPROC 