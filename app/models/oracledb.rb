class Oracledb < ApplicationRecord
  establish_connection "#{Rails.env}_sec".to_sym

  def self.getCreditosInmobiliarios
    # results = connection.exec_query("Select * from inmobiliario")
    results = connection.exec_query("
      select
      t.numero_operacion id_credito,
      t.codcl id_socio,
      (select s.mcli_razon_social||''||s.mcli_apellido_pat||' '||s.mcli_apellido_mat||' '||s.mcli_nombres from socios s where s.codigo_socio=c.codigo_socio)as NOMBRES,
      t.identificacion CEDULA,
      (select max(mcli_telefonos) from socios_direcciones where codigo_socio=c.codigo_socio)TELEFONO,
      (select max(mcli_telefono_celular) from socios_direcciones where codigo_socio=c.codigo_socio )CELULAR,
      (SELECT max(DS.mcli_calle_prin)||' '||MAX(DS.mcli_calle_secu) ||' '||MAX(DS.mcli_numerocasa)
          FROM SOCIOS_DIRECCIONES DS WHERE c.codigo_socio = DS.CODIGO_SOCIO
          AND DS.FECHA_INGRESO = (SELECT MAX(X.FECHA_INGRESO) FROM SOCIOS_DIRECCIONES X WHERE X.CODIGO_SOCIO = c.codigo_socio)
      )AS DIRECCION,
      (SELECT max(DS.TIPO_SECTOR)
          FROM SOCIOS_DIRECCIONES DS WHERE c.codigo_socio = DS.CODIGO_SOCIO
          AND DS.FECHA_INGRESO = (SELECT MAX(X.FECHA_INGRESO) FROM SOCIOS_DIRECCIONES X WHERE X.CODIGO_SOCIO = c.codigo_socio)
      )AS SECTOR,
      (
       SELECT MAX(DESCRIPCION) from Sifv_Parroquias d, socios_solisoc_datos_generales sod
         WHERE d.codigo_pais = substr(sod.sing_lugdir,1,2)
           and d.codigo_provincia = substr(sod.sing_lugdir,3,2)
           and d.codigo_ciudad = substr(sod.sing_lugdir,5,2)
           and d.codigo_parroquia = substr(sod.sing_lugdir,7,2)
           and sod.codigo_socio=c.codigo_socio
      ) AS PARROQUIA,
      (
       SELECT MAX(DESCRIPCION) from Sifv_Ciudades d, socios_solisoc_datos_generales sod
         WHERE d.codigo_pais = substr(sod.sing_lugdir,1,2)
           and d.codigo_provincia = substr(sod.sing_lugdir,3,2)
           and d.codigo_ciudad = substr(sod.sing_lugdir,5,2)
           and sod.codigo_socio=c.codigo_socio
      ) AS CANTON,
      (SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = c.codigo_grupo) AS NOM_GRUPO,
      (select descripcion from capta_cab_grupos_organizados cb, socios_solisoc_datos_generales s where cb.codigo_empresa_gruporg=s.codigo_gruporg
      and c.codigo_socio=s.codigo_socio) GRUPO_ORGANIZADO,
      (select descripcion from sifv_sucursales where codigo_sucursal=c.codigo_sucursal)SUCURSAL,
      (select usu_nombres||' '||usu_apellidos from sifv_usuarios_sistema where codigo_usuario=c.oficre) OFICIAL_CREDITO,
       (case when c.oficre in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                     when c.oficre in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                     when c.oficre in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                     when c.oficre in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                     when c.oficre in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                     when c.oficre in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                     when c.oficre in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                     when c.oficre in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                     when c.oficre in (85,26,83,48) then ('BALCON')
                     when c.oficre in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                     when c.oficre in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                     when c.oficre in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                     else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=c.oficre) end
               )CARTERA_HEREDADA,
      (select min(j.fecinical) from cred_tabla_amortiza_variable j
      where j.ordencal = (select min(i.ordencal)  from cred_tabla_amortiza_variable i
                          where i.numero_credito = c.NUMERO_CREDITO)
        and j.numero_credito = c.NUMERO_CREDITO) as FECHA_CONCESION,
      (select max(j.fecfincal) from cred_tabla_amortiza_variable j
      where j.ordencal = (select max(i.ordencal)  from cred_tabla_amortiza_variable i
                          where i.numero_credito = c.NUMERO_CREDITO)
        and j.numero_credito = c.NUMERO_CREDITO) as FECHA_VENCIMIENTO,
      c.monto_real MONTO_REAL,
      t.saldo_total SALDO_TOTAL,
      t.cuota_credito VALOR_CANCELA,--cuota_credito
      t.dias_morocidad DIASMORA_PD,
      t.provision_especifica PROVISION_REQUERIDA,
      (
       CASE (SELECT MAX(CODIGO_PRINCIPAL) FROM SOCIOS_GARANTIAS_REALES
             WHERE NUMERO_CREDITO = c.NUMERO_CREDITO)
             WHEN 1 THEN 'HIPOTECA'
             WHEN 2 THEN 'PRENDARIA'
             WHEN 3 THEN 'SESION DE DERECHOS'
             WHEN 4 THEN 'GARANTIAS DEL ESTADO'
             ELSE 'GARANTIA SOLIDARIA'
        END
       ) TIPO_GARANTIA,
       (SELECT MAX(TB.DESCRIPCION) FROM SOCIOS_TIPOS_BIENES TB, SOCIOS_GARANTIAS_REALES GR
        WHERE TB.CODIGO_BIEN = GR.CODIGO_BIEN
        AND GR.NUMERO_CREDITO = c.NUMERO_CREDITO
       )GARANTIA_REAL,
       (SELECT APELLIDOS||' '||NOMBRES FROM SOCIOS_GARANTIAS_FIDUCIARIAS
        WHERE NUM_REGISTRO = 1
        AND NUMERO_CREDITO = c.NUMERO_CREDITO
       )GARANTIA_FIDUCIARIA,
      (SELECT GARA_CALLE_PRIN || ' ' || GARA_NUMEROCASA || ' ' || GARA_CALLE_SECU
      FROM SOCIOS_GARANTES_DIRECCIONES WHERE CODIGO_SOCIO=c.CODIGO_SOCIO AND NUM_REGISTRO=(select max(num_registro)
      from SOCIOS_GARANTES_DIRECCIONES where codigo_socio=c.codigo_socio) and rownum=1
             AND TRIM(NUMERO_ID_GARANTE) IN
              (SELECT TRIM(NUMERO_ID) FROM SOCIOS_GARANTIAS_FIDUCIARIAS  where codigo_socio=c.codigo_socio and numero_credito=c.numero_credito and num_registro=2))  as DIR_GARANTE,
      (SELECT gara_telefonos
      FROM SOCIOS_GARANTES_DIRECCIONES WHERE CODIGO_SOCIO=c.CODIGO_SOCIO AND NUM_REGISTRO=(select max(num_registro)
      from SOCIOS_GARANTES_DIRECCIONES where codigo_socio=c.codigo_socio) and rownum=1
             AND TRIM(NUMERO_ID_GARANTE) IN
              (SELECT TRIM(NUMERO_ID) FROM SOCIOS_GARANTIAS_FIDUCIARIAS  where codigo_socio=c.codigo_socio and numero_credito=c.numero_credito and num_registro=2))  as TELF_GARANTE,
      t.calificacion_propia CALIFICACION_PROPIA,
      t.valor_cartera_castigada VALOR_CARTERA_CASTIGADA,
      (case when (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('TERRENOS','CASAS','VEHICULOS'))=0 then 'NO'
            when (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('TERRENOS','CASAS','VEHICULOS'))is null then 'NO'
            ELSE 'SI' end
      --select * from cred_ctas_contables_temp_x_usu where codigo_socio=11299
      )BIENES,
      (case --(select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('TERRENOS','CASAS','VEHICULOS')
            when ((select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('TERRENOS'))>0
            and (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('CASAS'))>0
            and (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('VEHICULOS'))>0) then 'TCV'
            when ((select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('TERRENOS'))>0
            and (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('CASAS'))>0)then 'TC'
            when ((select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('CASAS'))>0
            and (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('VEHICULOS'))>0) then 'CV'
            when ((select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('TERRENOS'))>0
            and (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('VEHICULOS'))>0) then 'TV'
            when (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('TERRENOS'))>0 then 'T'
            when (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('CASAS'))>0 then 'C'
            when (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('VEHICULOS'))>0 then 'V'
            else 'NO DISPONE' end)BIEN
            ,(SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = c.codigo_grupo) AS  TIPO_CREDITO,
             (select apellidos||' '||nombres from socios_garantias_fiduciarias where c.numero_credito=numero_credito and num_registro=1)nom_garante1,
            (select numero_id from socios_garantias_fiduciarias where c.numero_credito=numero_credito and num_registro=1)ci_garante_1,
            (select sc.codigo_numero_id from socios so, socios_datos_conyuges sc where so.codigo_socio=sc.codigo_socio
      and so.mcli_numero_id=(select numero_id from socios_garantias_fiduciarias where c.numero_credito=numero_credito and num_registro=1))
       cony_garante1,
            (select apellidos||' '||nombres from socios_garantias_fiduciarias where c.numero_credito=numero_credito and num_registro=2)nom_garante2,
            (select numero_id from socios_garantias_fiduciarias where c.numero_credito=numero_credito and num_registro=2)ci_garante2,
            (select sc.codigo_numero_id from socios so, socios_datos_conyuges sc where so.codigo_socio=sc.codigo_socio
      and so.mcli_numero_id=(select numero_id from socios_garantias_fiduciarias where c.numero_credito=numero_credito and num_registro=2))
       cony_garante2,
      (select MAX(gara_avaluo_comercial) from socios_garantias_reales where numero_credito=t.numero_operacion) valor_avaluo_comercial,
       (select MAX(gara_avaluo_catastral) from socios_garantias_reales where numero_credito=t.numero_operacion) valor_avaluo_catastral,
       (select MAX(gara_avaluo) from socios_garantias_reales where numero_credito=t.numero_operacion) avaluo_titulo,
       t.interes_ordinario interes,
       t.interes_sobre_mora mora,
       t.valor_gtos_recup_cart_jud gastos_judiciales,
       t.valor_gtos_recup_cart_extjud gastos_extra_judicial,
       t.valor_demanda_judicial demanda_judicial,
       (t.saldo_total + t.interes_ordinario+t.interes_sobre_mora+t.valor_gtos_recup_cart_extjud+t.valor_gtos_recup_cart_jud+t.valor_demanda_judicial)
       total_adeudado

      from temp_c02 t, cred_creditos c
      where t.dias_morocidad>=271 and c.codigo_grupo in (3) --inmobiliario
      and c.numero_credito=t.numero_operacion")
    if results.present?
      return results
    else
      return nil
    end
  end

  def self.getCreditosConsumo
    # results = connection.exec_query("Select * from consumo")
    results = connection.exec_query("
      select
      t.numero_operacion id_credito,
      t.codcl id_socio,
      (select s.mcli_razon_social||''||s.mcli_apellido_pat||' '||s.mcli_apellido_mat||' '||s.mcli_nombres from socios s where s.codigo_socio=c.codigo_socio)as NOMBRES,
      t.identificacion CEDULA,
      (select max(mcli_telefonos) from socios_direcciones where codigo_socio=c.codigo_socio)TELEFONO,
      (select max(mcli_telefono_celular) from socios_direcciones where codigo_socio=c.codigo_socio )CELULAR,
      (SELECT max(DS.mcli_calle_prin)||' '||MAX(DS.mcli_calle_secu) ||' '||MAX(DS.mcli_numerocasa)
          FROM SOCIOS_DIRECCIONES DS WHERE c.codigo_socio = DS.CODIGO_SOCIO
          AND DS.FECHA_INGRESO = (SELECT MAX(X.FECHA_INGRESO) FROM SOCIOS_DIRECCIONES X WHERE X.CODIGO_SOCIO = c.codigo_socio)
      )AS DIRECCION,
      (SELECT max(DS.TIPO_SECTOR)
          FROM SOCIOS_DIRECCIONES DS WHERE c.codigo_socio = DS.CODIGO_SOCIO
          AND DS.FECHA_INGRESO = (SELECT MAX(X.FECHA_INGRESO) FROM SOCIOS_DIRECCIONES X WHERE X.CODIGO_SOCIO = c.codigo_socio)
      )AS SECTOR,
      (
       SELECT MAX(DESCRIPCION) from Sifv_Parroquias d, socios_solisoc_datos_generales sod
         WHERE d.codigo_pais = substr(sod.sing_lugdir,1,2)
           and d.codigo_provincia = substr(sod.sing_lugdir,3,2)
           and d.codigo_ciudad = substr(sod.sing_lugdir,5,2)
           and d.codigo_parroquia = substr(sod.sing_lugdir,7,2)
           and sod.codigo_socio=c.codigo_socio
      ) AS PARROQUIA,
      (
       SELECT MAX(DESCRIPCION) from Sifv_Ciudades d, socios_solisoc_datos_generales sod
         WHERE d.codigo_pais = substr(sod.sing_lugdir,1,2)
           and d.codigo_provincia = substr(sod.sing_lugdir,3,2)
           and d.codigo_ciudad = substr(sod.sing_lugdir,5,2)
           and sod.codigo_socio=c.codigo_socio
      ) AS CANTON,
      (SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = c.codigo_grupo) AS NOM_GRUPO,
      (select descripcion from capta_cab_grupos_organizados cb, socios_solisoc_datos_generales s where cb.codigo_empresa_gruporg=s.codigo_gruporg
      and c.codigo_socio=s.codigo_socio) GRUPO_ORGANIZADO,
      (select descripcion from sifv_sucursales where codigo_sucursal=c.codigo_sucursal)SUCURSAL,
      (select usu_nombres||' '||usu_apellidos from sifv_usuarios_sistema where codigo_usuario=c.oficre) OFICIAL_CREDITO,
       (case when c.oficre in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                     when c.oficre in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                     when c.oficre in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                     when c.oficre in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                     when c.oficre in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                     when c.oficre in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                     when c.oficre in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                     when c.oficre in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                     when c.oficre in (85,26,83,48) then ('BALCON')
                     when c.oficre in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                     when c.oficre in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                     when c.oficre in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                     else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=c.oficre) end
               )CARTERA_HEREDADA,
      (select min(j.fecinical) from cred_tabla_amortiza_variable j
      where j.ordencal = (select min(i.ordencal)  from cred_tabla_amortiza_variable i
                          where i.numero_credito = c.NUMERO_CREDITO)
        and j.numero_credito = c.NUMERO_CREDITO) as FECHA_CONCESION,
      (select max(j.fecfincal) from cred_tabla_amortiza_variable j
      where j.ordencal = (select max(i.ordencal)  from cred_tabla_amortiza_variable i
                          where i.numero_credito = c.NUMERO_CREDITO)
        and j.numero_credito = c.NUMERO_CREDITO) as FECHA_VENCIMIENTO,
      c.monto_real MONTO_REAL,
      t.saldo_total SALDO_TOTAL,
      t.cuota_credito VALOR_CANCELA,--cuota_credito
      t.dias_morocidad DIASMORA_PD,
      t.provision_especifica PROVISION_REQUERIDA,
      (
       CASE (SELECT MAX(CODIGO_PRINCIPAL) FROM SOCIOS_GARANTIAS_REALES
             WHERE NUMERO_CREDITO = c.NUMERO_CREDITO)
             WHEN 1 THEN 'HIPOTECA'
             WHEN 2 THEN 'PRENDARIA'
             WHEN 3 THEN 'SESION DE DERECHOS'
             WHEN 4 THEN 'GARANTIAS DEL ESTADO'
             ELSE 'GARANTIA SOLIDARIA'
        END
       ) TIPO_GARANTIA,
       (SELECT MAX(TB.DESCRIPCION) FROM SOCIOS_TIPOS_BIENES TB, SOCIOS_GARANTIAS_REALES GR
        WHERE TB.CODIGO_BIEN = GR.CODIGO_BIEN
        AND GR.NUMERO_CREDITO = c.NUMERO_CREDITO
       )GARANTIA_REAL,
       (SELECT APELLIDOS||' '||NOMBRES FROM SOCIOS_GARANTIAS_FIDUCIARIAS
        WHERE NUM_REGISTRO = 1
        AND NUMERO_CREDITO = c.NUMERO_CREDITO
       )GARANTIA_FIDUCIARIA,
      (SELECT GARA_CALLE_PRIN || ' ' || GARA_NUMEROCASA || ' ' || GARA_CALLE_SECU
      FROM SOCIOS_GARANTES_DIRECCIONES WHERE CODIGO_SOCIO=c.CODIGO_SOCIO AND NUM_REGISTRO=(select max(num_registro)
      from SOCIOS_GARANTES_DIRECCIONES where codigo_socio=c.codigo_socio) and rownum=1
             AND TRIM(NUMERO_ID_GARANTE) IN
              (SELECT TRIM(NUMERO_ID) FROM SOCIOS_GARANTIAS_FIDUCIARIAS  where codigo_socio=c.codigo_socio and numero_credito=c.numero_credito and num_registro=2))  as DIR_GARANTE,
      (SELECT gara_telefonos
      FROM SOCIOS_GARANTES_DIRECCIONES WHERE CODIGO_SOCIO=c.CODIGO_SOCIO AND NUM_REGISTRO=(select max(num_registro)
      from SOCIOS_GARANTES_DIRECCIONES where codigo_socio=c.codigo_socio) and rownum=1
             AND TRIM(NUMERO_ID_GARANTE) IN
              (SELECT TRIM(NUMERO_ID) FROM SOCIOS_GARANTIAS_FIDUCIARIAS  where codigo_socio=c.codigo_socio and numero_credito=c.numero_credito and num_registro=2))  as TELF_GARANTE,
      t.calificacion_propia CALIFICACION_PROPIA,
      t.valor_cartera_castigada VALOR_CARTERA_CASTIGADA,
      (case when (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('TERRENOS','CASAS','VEHICULOS'))=0 then 'NO'
            when (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('TERRENOS','CASAS','VEHICULOS'))is null then 'NO'
            ELSE 'SI' end
      --select * from cred_ctas_contables_temp_x_usu where codigo_socio=11299
      )BIENES,
      (case --(select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('TERRENOS','CASAS','VEHICULOS')
            when ((select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('TERRENOS'))>0
            and (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('CASAS'))>0
            and (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('VEHICULOS'))>0) then 'TCV'
            when ((select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('TERRENOS'))>0
            and (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('CASAS'))>0)then 'TC'
            when ((select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('CASAS'))>0
            and (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('VEHICULOS'))>0) then 'CV'
            when ((select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('TERRENOS'))>0
            and (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('VEHICULOS'))>0) then 'TV'
            when (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('TERRENOS'))>0 then 'T'
            when (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('CASAS'))>0 then 'C'
            when (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('VEHICULOS'))>0 then 'V'
            else 'NO DISPONE' end)BIEN
            ,(SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = c.codigo_grupo) AS  TIPO_CREDITO,
             (select apellidos||' '||nombres from socios_garantias_fiduciarias where c.numero_credito=numero_credito and num_registro=1)nom_garante1,
            (select numero_id from socios_garantias_fiduciarias where c.numero_credito=numero_credito and num_registro=1)ci_garante_1,
            (select sc.codigo_numero_id from socios so, socios_datos_conyuges sc where so.codigo_socio=sc.codigo_socio
      and so.mcli_numero_id=(select numero_id from socios_garantias_fiduciarias where c.numero_credito=numero_credito and num_registro=1))
       cony_garante1,
            (select apellidos||' '||nombres from socios_garantias_fiduciarias where c.numero_credito=numero_credito and num_registro=2)nom_garante2,
            (select numero_id from socios_garantias_fiduciarias where c.numero_credito=numero_credito and num_registro=2)ci_garante2,
            (select sc.codigo_numero_id from socios so, socios_datos_conyuges sc where so.codigo_socio=sc.codigo_socio
      and so.mcli_numero_id=(select numero_id from socios_garantias_fiduciarias where c.numero_credito=numero_credito and num_registro=2))
       cony_garante2,
      (select MAX(gara_avaluo_comercial) from socios_garantias_reales where numero_credito=t.numero_operacion) valor_avaluo_comercial,
       (select MAX(gara_avaluo_catastral) from socios_garantias_reales where numero_credito=t.numero_operacion) valor_avaluo_catastral,
       (select MAX(gara_avaluo) from socios_garantias_reales where numero_credito=t.numero_operacion) avaluo_titulo,
       t.interes_ordinario interes,
       t.interes_sobre_mora mora,
       t.valor_gtos_recup_cart_jud gastos_judiciales,
       t.valor_gtos_recup_cart_extjud gastos_extra_judicial,
       t.valor_demanda_judicial demanda_judicial,
       (t.saldo_total + t.interes_ordinario+t.interes_sobre_mora+t.valor_gtos_recup_cart_extjud+t.valor_gtos_recup_cart_jud+t.valor_demanda_judicial)
       total_adeudado

      from temp_c02 t, cred_creditos c
      where t.dias_morocidad>=96 and c.codigo_grupo in (2,4)--consumo y micro
      and c.numero_credito=t.numero_operacion")
    if results.present?
      return results
    else
      return nil
    end

  end

  def self.getCreditosMicrocreditos
    results = connection.exec_query("Select * from microcredito")
    if results.present?
      return results
    else
      return nil
    end
  end

  def self.getCreditosProductivos
    results = connection.exec_query("Select * from productivo")
    if results.present?
      return results
    else
      return nil
    end
  end

  def self.getVariables credit_id
    results = connection.exec_query("Select * from variables where credit_id = '#{credit_id}'")
    if results.present?
      return results
    else
      return nil
    end
  end

  # Obtiene una fila del archivo creditos_nuevos.txt con la finalidad
  # de obtener los saldos del credito sin tener que consultar a la base
  # de datos
  def self.getSaldos credit_id
    filename =  "creditos_nuevos.txt"
    data = Marshal.load File.read(Rails.public_path.join("creditos",filename))
    data.each do |row|
      if row['credito'] == credit_id
        resultado = row
        return resultado
      end
    end
    # results = {monto_real: '100', saldo_total: "200" }
     results = connection.exec_query("select
      (select monto_real from cred_creditos where numero_credito=t.numero_operacion)monto_real,
      t.saldo_total,t.cuota_credito valor_cancela,t.dias_morocidad AS diasmora_pd,t.provision_especifica AS provision_requerida,t.calificacion_propia,
      (select gara_avaluo_comercial from socios_garantias_reales where numero_credito=t.numero_operacion) valor_avaluo_comercial,
       (select gara_avaluo_catastral from socios_garantias_reales where numero_credito=t.numero_operacion) valor_avaluo_catastral,
       (select gara_avaluo from socios_garantias_reales where numero_credito=t.numero_operacion) avaluo_titulo,
       t.interes_ordinario interes,
       t.interes_sobre_mora mora,
       t.valor_gtos_recup_cart_jud gastos_judiciales,
       (case when t.valor_gtos_recup_cart_extjud is null then 0 else t.valor_gtos_recup_cart_extjud end) gastos_extra_judicial,
       t.valor_demanda_judicial demanda_judicial,
       (t.saldo_total + t.interes_ordinario+t.interes_sobre_mora+(case when t.valor_gtos_recup_cart_extjud is null then 0 else t.valor_gtos_recup_cart_extjud end)+t.valor_gtos_recup_cart_jud+t.valor_demanda_judicial)
       total_adeudado,
       t.codcl socio,
       (select mcli_telefonos from socios_direcciones where codigo_socio=t.codcl) telefono,
       (select mcli_telefono_celular from socios_direcciones where codigo_socio=t.codcl) celular,
       (select mcli_calle_prin ||' '||mcli_numerocasa||' '||mcli_calle_secu from socios_direcciones where codigo_socio=t.codcl) direccion,
       (select mcli_sector from socios_direcciones where codigo_socio=t.codcl)sector,
       (
          SELECT descripcion from Sifv_Parroquias d, SOCIOS_DIRECCIONES SD
              WHERE d.codigo_pais = substr(sd.mcli_lugar_dir,1,2)
              and d.codigo_provincia = substr(sd.mcli_lugar_dir,3,2)
              and d.codigo_ciudad = substr(sd.mcli_lugar_dir,5,2)
              and d.codigo_parroquia = substr(sd.mcli_lugar_dir,7,2)
              and sd.codigo_socio=t.codcl
       ) AS PARROQUIA,
       (
          SELECT descripcion from sifv_ciudades d, SOCIOS_DIRECCIONES SD
              WHERE d.codigo_pais = substr(sd.mcli_lugar_dir,1,2)
              and d.codigo_provincia = substr(sd.mcli_lugar_dir,3,2)
              and d.codigo_ciudad = substr(sd.mcli_lugar_dir,5,2)
            and sd.codigo_socio=t.codcl
        ) AS CANTON,
       (select max(gara_calle_prin ||' '||gara_numerocasa||' '||gara_calle_secu) from socios_garantes_direcciones where codigo_socio=t.codcl and num_registro=1) direccion_garante,
       (select max(gara_telefonos) from socios_garantes_direcciones  where codigo_socio=t.codcl and num_registro=1) telefono_garante
      from temp_c02 t
      where t.numero_operacion='" + credit_id + "'")
    if results.present?
      return results[0]
    else
      return {monto_real: 'NaN', saldo_total: "NaN", sector: "NaN", canton: "NaN", parroquia: "NaN", telefono: "NaN", celular: "NaN", valor_cancela: "NaN", gastos_extra_judicial: "NaN", valor_judicial: "NaN", diasmora_pd: "NaN", provision_requerida: "NaN", calificacion_propia: "NaN", demanda_judicial: "NaN", interes: "NaN", mora: "NaN", gastos_judiciales: "NaN", total_adeudado: "NaN", valor_avaluo_comercial: "NaN", valor_avaluo_catastral: "NaN", avaluo_titulo: "NaN", dir_garante: "NaN", tel_garante: "NaN"  }
    end
  end


  def self.guardar_creditos_pendientes
    inmobiliarios = Oracledb.getCreditosInmobiliarios.to_a
    # productivos = Oracledb.getCreditosProductivos.to_a
    # microcreditos = Oracledb.getCreditosMicrocreditos.to_a
    consumos = Oracledb.getCreditosConsumo.to_a
    juicios = inmobiliarios + consumos
    # guardar_creditos_pendientes

    filename =  "creditos_nuevos.txt"
    file = File.open(Rails.public_path.join("creditos",filename), "wb")
    serialized_array = Marshal.dump(juicios)
    File.open(file, "wb"){ |f| f << serialized_array }
  end

  def self.obtener_creditos_pendientes
    filename =  "creditos_nuevos.txt"
    data = Marshal.load File.read(Rails.public_path.join("creditos",filename))
    data
  end


  def self.buscar_credito_by_id_credito credito
    filename =  "creditos_nuevos.txt"
    data = Marshal.load File.read(Rails.public_path.join("creditos",filename))
    data.each do |row|
      if row['credito'] == credito
        resultado = row
        return resultado
      end
    end
    return nil
  end

  #   Modulo de Creditos
  def self.obtener_creditos_por_vencer fecha_inicio, fecha_fin, agencia, asesor, diaInicio, diaFin
    if asesor == " "
      asesor = ""
    end
    if agencia == " "
      agencia = ""
    end

    results = connection.exec_query("
      select
    (select codigo_socio from cred_creditos where numero_credito=ct.numero_credito) SOCIO,
    ct.numero_credito CREDITO,
    (select s.mcli_razon_social||''||mcli_apellido_pat||' '||mcli_apellido_mat||' '||mcli_nombres from socios s, cred_creditos c where s.codigo_socio=c.codigo_socio and numero_credito=ct.numero_credito)NOMBRE,
    (select c.fecha_credito from cred_creditos c where numero_credito=ct.numero_credito)  fecha_concesion,
    (select c.monto_real from cred_creditos c where numero_credito=ct.numero_credito) monto_real,
    (select c.saldo_capital from cred_creditos c where numero_credito=ct.numero_credito) saldo_cartera,
    NVL((select total
                      from CRED_TABLA_AMORTIZA_CONTRATADA
                      WHERE NUMERO_CREDITO=ct.NUMERO_CREDITO
                      and orden in (select max(orden) from cred_tabla_amortiza_contratada
                                    where FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                                    and NUMERO_CREDITO=ct.NUMERO_CREDITO)
                      AND FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      ),0) saldo,

                  -- select * from histo_tabla_amortiza_variable
    (select sum(valor) from cred_cabecera_pagos_credito where numero_credito=ct.numero_credito and
    trunc(FECHA) BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
    )pago,
    (select max(trunc(fecha)) from cred_cabecera_pagos_credito where numero_credito=ct.numero_credito and
    trunc(FECHA) BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
    )pago_realizado,

    (select round(t.provision_especifica,2) from temp_c02 t where t.numero_operacion=ct.numero_credito) provision,
    (select min(fecfincal) from cred_tabla_amortiza_variable where ordencal=orden and numero_credito=ct.numero_credito) fecha,
    (select t.Dias_Morocidad from temp_c02 t where t.numero_operacion=ct.numero_credito) dias_mora,
    (select descripcion from  sifv_sucursales s, cred_creditos c where numero_credito=ct.numero_credito and c.codigo_sucursal=s.codigo_sucursal) sucursal ,
    (select usu_apellidos||' '||usu_nombres from  sifv_usuarios_sistema s, cred_creditos c where numero_credito=ct.numero_credito and c.oficre=s.codigo_usuario) cartera_heredada,
    (case when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                   else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=(select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito)) end
             )asesor
    from cred_tabla_amortiza_contratada ct
    where trunc(ct.fecha)between to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') and  to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
    and (select estado_cred from cred_creditos where numero_credito=ct.numero_credito)in 'L'
    and (select descripcion from  sifv_sucursales s, cred_creditos c where numero_credito=ct.numero_credito and c.codigo_sucursal=s.codigo_sucursal) like upper ('%#{agencia}%')
    and ((case when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                   when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                   else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=(select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito)) end
             ))like upper ('%#{asesor}%')
            and (select t.Dias_Morocidad from temp_c02 t where t.numero_operacion=ct.numero_credito) between #{diaInicio.to_i} and #{diaFin.to_i}
      ")


    if results.present?
      return results
    else
      return {}
    end


    firstWeek = [
    {
        credito: 17654,
        socio: 23423,
        saldo: 23809.073,
        nombre: 'Santiago Lopez',
        fecha: '1-12-2017',
        sucursal: 'Matriz',
        asesor: 'Roberto',
        provision: 345346.2
    },
    {
        credito: 9999345,
        socio: 4566,
        saldo: 645334.876,
        nombre: 'Sebastian Lopez',
        fecha: '1-12-2017',
        sucursal: 'La Merced',
        asesor: 'Romel',
        provision: 345346.24
    },
    {
        credito: 234,
        socio: 867,
        saldo: 1023.506,
        nombre: 'Valentina Aguirre',
        fecha: '2-12-2017',
        sucursal: 'Atuntaqui',
        asesor: 'Daniela',
        provision: 3234.25
    },
    {
        credito: 5467,
        socio: 567,
        saldo: 406534.768,
        nombre: 'Cristian Guerra',
        fecha: '2/12/2017',
        sucursal: 'La Merced',
        asesor: 'Chloe',
        provision: 8656.24
    },
    {
        credito: 17345654,
        socio: 7585,
        saldo: 75685.34658,
        nombre: 'Tatiana Lopez',
        fecha: '3/12/2017',
        sucursal: 'La Merced',
        asesor: 'Israel',
        provision: 7563.265
    },
    {
        credito: 4564,
        socio: 765,
        saldo: 34564.5685,
        nombre: 'Isabella Lopez',
        fecha: '4/12/2017',
        sucursal: 'Matriz',
        asesor: 'Santiago',
        provision: 5322.2
    },{
        credito: 17654,
        socio: 23423,
        saldo: 2000,
        nombre: 'Santiago Lopez',
        fecha: '8/12/2017',
        sucursal: 'Matriz',
        asesor: 'Rooberto'
    },{
        credito: 234,
        socio: 867,
        saldo: 2000,
        nombre: 'Valentina Aguirre',
        fecha: '9/12/2017',
        sucursal: 'Atuntaqui',
        asesor: 'Daniela'
    },{
        credito: 17345654,
        socio: 7585,
        saldo: 2000,
        nombre: 'Tatiana Lopez',
        fecha: '10/12/2017',
        sucursal: 'La Merced',
        asesor: 'Israel'
    },{
        credito: 4564,
        socio: 765,
        saldo: 2000,
        nombre: 'Isabella Lopez',
        fecha: '12/12/2017',
        sucursal: 'Matriz',
        asesor: 'Santiago'
    },{
     credito: 17654,
     socio: 23423,
     saldo: 3000,
     nombre: 'Santiago Lopez',
     fecha: '16/12/2017',
     sucursal: 'Matriz',
     asesor: 'Roberto'
    },{
     credito: 234,
     socio: 867,
     saldo: 3000,
     nombre: 'Valentina Aguirre',
     fecha: '17/12/2017',
     sucursal: 'Atuntaqui',
     asesor: 'Daniela'
    },{
     credito: 17345654,
     socio: 7585,
     saldo: 3000,
     nombre: 'Tatiana Lopez',
     fecha: '18/12/2017',
     sucursal: 'La Merced',
     asesor: 'Israel'
    },{
     credito: 4564,
     socio: 765,
     saldo: 3000,
     nombre: 'Isabella Lopez',
     fecha: '19/12/2017',
     sucursal: 'Matriz',
     asesor: 'Santiago'
    },{
        credito: 17654,
        socio: 23423,
        saldo: 4000,
        nombre: 'Santiago Lopez',
        fecha: '24/12/2017',
        sucursal: 'Matriz',
        asesor: 'Daniela'
    },{
        credito: 234,
        socio: 867,
        saldo: 4000,
        nombre: 'Valentina Aguirre',
        fecha: '25/12/2017',
        sucursal: 'La Merced',
        asesor: 'Daniela'
    },{
        credito: 17345654,
        socio: 7585,
        saldo: 4000,
        nombre: 'Tatiana Lopez',
        fecha: '26/12/2017',
        sucursal: 'La Merced',
        asesor: 'Daniela'
    },{
        credito: 4564,
        socio: 765,
        saldo: 4000,
        nombre: 'Isabella Lopez',
        fecha: '27/12/2017',
        sucursal: 'Matriz',
        asesor: 'Daniela'
    }]
  end

  def self.cartera_recuperada fecha_inicio, fecha_fin, agencia, asesor, diaInicio, diaFin
    results = connection.exec_query("
    select
    (select codigo_socio from cred_creditos where numero_credito=ct.numero_credito) SOCIO,
    ct.numero_credito CREDITO,
    (select s.mcli_razon_social||''||mcli_apellido_pat||' '||mcli_apellido_mat||' '||mcli_nombres from socios s, cred_creditos c where s.codigo_socio=c.codigo_socio and numero_credito=ct.numero_credito)NOMBRE,
    (select c.fecha_credito from cred_creditos c where numero_credito=ct.numero_credito)  fecha_concesion,
    (select c.monto_real from cred_creditos c where numero_credito=ct.numero_credito) monto_real,
    (select c.saldo_capital from cred_creditos c where numero_credito=ct.numero_credito) saldo_cartera,
    NVL((select total
                from CRED_TABLA_AMORTIZA_CONTRATADA
                WHERE NUMERO_CREDITO=ct.NUMERO_CREDITO
                and orden in (select max(orden) from cred_tabla_amortiza_contratada
                              where FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                              and NUMERO_CREDITO=ct.NUMERO_CREDITO)
                AND FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                ),0) saldo,

            -- select * from histo_tabla_amortiza_variable
    (select sum(valor) from cred_cabecera_pagos_credito where numero_credito=ct.numero_credito and
    trunc(FECHA) BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
    )pago,
    (select max(trunc(fecha)) from cred_cabecera_pagos_credito where numero_credito=ct.numero_credito and
    trunc(FECHA) BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
    )pago_realizado,

    (select round(t.provision_especifica,2) from temp_c02 t where t.numero_operacion=ct.numero_credito) provision,
    -- ct.fecfincal fecha,
    (select t.Dias_Morocidad from temp_c02 t where t.numero_operacion=ct.numero_credito) dias_mora,
    (select descripcion from  sifv_sucursales s, cred_creditos c where numero_credito=ct.numero_credito and c.codigo_sucursal=s.codigo_sucursal) sucursal ,
    (select usu_apellidos||' '||usu_nombres from  sifv_usuarios_sistema s, cred_creditos c where numero_credito=ct.numero_credito and c.oficre=s.codigo_usuario) cartera_heredada,
    (case when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
             else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=(select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito)) end
       )asesor
    from cred_tabla_amortiza_contratada ct
    where trunc(ct.fecha)between to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') and  to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
    and (select estado_cred from cred_creditos where numero_credito=ct.numero_credito)in 'L'
    and (select descripcion from  sifv_sucursales s, cred_creditos c where numero_credito=ct.numero_credito and c.codigo_sucursal=s.codigo_sucursal) like ('%#{agencia}%')
    and ((case when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
             when (select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito) in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
             else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=(select c.oficre from cred_creditos c where c.numero_credito=ct.numero_credito)) end
       ))like upper ('%#{asesor}%')
      and (select t.Dias_Morocidad from temp_c02 t where t.numero_operacion=ct.numero_credito) between #{diaInicio.to_i} and #{diaFin.to_i}
    ")

    if results.present?
      return results
    else
      return {}
    end
  end

  def self.obtener_creditos_por_asesor fecha, diaInicio, diaFin
    results = connection.exec_query("
    SELECT TAB.ASESORES, COUNT(TAB.CREDITO) NUM_CREDITOS,
    SUM(TAB.MONTO) MONTO_CREDITO,
    SUM(TAB.CAPITAL_NO_DEVENGA) CAP_NDEVENGA,
    SUM(TAB.CAPITAL_VENCIDO) CAP_VENCIDO,
    SUM(TAB.CAPITAL_ACTIVO) CAP_ACTIVO,
    SUM(CARTERA_RIESGO) CARTERA_AFECTADA,
    SUM(SALDO_CARTERA) SALDO_CARTERA
    FROM (
        SELECT TH1.CREDITO, TH1.MONTO, TH1.SALDO,
              th1.asesor ASESORES, TH1.CAP_ACTIVO CAPITAL_ACTIVO,TH1.CAP_NDEVENGA CAPITAL_NO_DEVENGA, TH1.CAP_VENCIDO CAPITAL_VENCIDO,
              (TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)CARTERA_RIESGO,
              TH1.DIASMORA_PD,
              (TH1.CAP_ACTIVO+TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)SALDO_CARTERA,
              (SELECT SUM(SC.CAPITAL) TCAPITAL  FROM CRED_HISTORIAL_REC_CARTERA SC WHERE TRUNC(SC.FGENERA) = to_date('"+ fecha.to_date.strftime('%d-%m-%Y') +"','dd/mm/yyyy'))AS TSALDO
        FROM(
            SELECT
                TH.NUMERO_CREDITO AS CREDITO, MAX(TH.MON_REAL) MONTO,th.asesor asesor,
                SUM(TH.DIASMORAPD) DIASMORA_PD,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('I') THEN TH.SCAPITAL ELSE 0 END) AS CAP_ACTIVO,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('D') THEN TH.SCAPITAL ELSE 0 END) AS CAP_NDEVENGA,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('E') THEN TH.SCAPITAL ELSE
                   (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
                   END) AS CAP_VENCIDO,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE 0 END) AS SALDO
            FROM(
                SELECT CC.NUMERO_CREDITO, CH.ESTADO_CARSEG, MAX(CC.MONTO_REAL) MON_REAL, SUM(CAPITAL) AS SCAPITAL,
                MAX(CH.DIAMORACT)AS DIASMORAPD,
                (case when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                   else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=(select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO)) end
             )asesor
                  FROM CRED_CREDITOS CC, CRED_HISTORIAL_REC_CARTERA CH
                 WHERE CC.NUMERO_CREDITO = CH.NUMERO_CREDITO
                   AND TRUNC(CH.FGENERA) = to_date('"+ fecha.to_date.strftime('%d-%m-%Y') +"','dd/mm/yyyy')
                 GROUP BY CC.NUMERO_CREDITO, CH.ESTADO_CARSEG
            )TH GROUP BY TH.NUMERO_CREDITO,th.asesor
        )TH1
    where TH1.DIASMORA_PD between #{diaInicio} and #{diaFin}
    )TAB
    GROUP BY TAB.ASESORES
    ORDER BY TAB.ASESORES
    ")

    if results.present?
      return results
    else
      return {}
    end

    data = [{
        asesores: 'Santiago Lopez',
        cap_activo: 23422.223,
        cap_ndevenga: 234234.5345,
        cap_vencido: 83739.9458,
        cartera_afectada: 943598.3452,
        saldo_cartera: 2393240.0234,
    },{
        asesores: 'Chlor Wrigth',
        cap_activo: 23422.223,
        cap_ndevenga: 234234.5345,
        cap_vencido: 83739.9458,
        cartera_afectada: 943598.3452,
        saldo_cartera: 2393240.0234,
    },{
        asesores: 'Daniela Ruiz',
        cap_activo: 23422.223,
        cap_ndevenga: 234234.5345,
        cap_vencido: 83739.9458,
        cartera_afectada: 943598.3452,
        saldo_cartera: 2393240.0234,
    },{
        asesores: 'Sofia Guerra',
        cap_activo: 23422.223,
        cap_ndevenga: 234234.5345,
        cap_vencido: 83739.9458,
        cartera_afectada: 943598.3452,
        saldo_cartera: 2393240.0234,
    },{
        asesores: 'Valentina Amador',
        cap_activo: 23422.223,
        cap_ndevenga: 234234.5345,
        cap_vencido: 83739.9458,
        cartera_afectada: 943598.3452,
        saldo_cartera: 2393240.0234
    }]
    return data
  end

  def self.obtener_creditos_de_asesor nombre, diaInicio, diaFin, fecha

    results = connection.exec_query("
    SELECT
    TH1.FECHA_INGRESO FECHA_INGRESO,
    (select MAX(descripcion) from cred_tipos_recursos_economicos where codigo = TH1.ORIGENR) as ORIGEN_RECURSOS,
    TH1.SOCIO,
    TH1.NUMERO_CREDITO CREDITO,
    (select tt.provision_especifica from temp_c02 tt where tt.numero_operacion=th1.numero_credito)provision_requerida,
    TH1.CODIGO_PERIOC,
    (TH1.NUM_CUOTAS) AS CUOTAS_CREDITO,
    CASE WHEN TH1.TIP_ID = 'R' THEN TH1.EMPRESA ELSE TH1.NOMBRE END NOMBRE,
    TH1.TIP_ID,
    TH1.CEDULA,
    TH1.GENERO GENERO,
    TRUNC((SYSDATE-TH1.EDAD)/365.25)EDAD,
    th1.edad fecha_nacimiento,

    TH1.CALIFICACION,
    TH1.CAP_ACTIVO,
    TH1.CAP_NDEVENGA,
    TH1.CAP_VENCIDO,
    (TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)CARTERA_RIESGO,
    (TH1.CAP_ACTIVO+
    TH1.CAP_NDEVENGA+
    TH1.CAP_VENCIDO)saldo_cartera,

    /*FECHA CONCESION*/
    (select min(j.fecinical) from cred_tabla_amortiza_variable j
    where j.ordencal = (select min(i.ordencal)  from cred_tabla_amortiza_variable i
                        where i.numero_credito = TH1.NUMERO_CREDITO)
      and j.numero_credito = TH1.NUMERO_CREDITO) as FECHA_CONCESION,
    /*FECHA_VENCIMIENTO*/
    (select max(j.fecfincal) from cred_tabla_amortiza_variable j
    where j.ordencal = (select max(i.ordencal)  from cred_tabla_amortiza_variable i
                        where i.numero_credito = TH1.NUMERO_CREDITO)
      and j.numero_credito = TH1.NUMERO_CREDITO) as FECHA_VENCIMIENTO,
    (select SUM(ROUND(NVL(CAPITALCAL,0),2) + ROUND(NVL(INTERESCAL,0),2) + ROUND(NVL(MORACAL,0),2) +
              ROUND(CASE WHEN trunc(fecinical)>trunc(sysdate) THEN 0 ELSE NVL(rubroscal,0) END,2)) from CRED_TABLA_AMORTIZA_VARIABLE A
                         where a.numero_credito=TH1.numero_credito
                         and estadocal='P')valor_cancela,
    TH1.DIASMORA_PD,
    TH1.SUCURSAL OFICINA,
    TH1.NOM_OF_CRE CARTERA_HEREDADA,
             (case when th1.oficial_credito in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                   when th1.oficial_credito in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                   when th1.oficial_credito in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                   when th1.oficial_credito in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                   when th1.oficial_credito in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                   when th1.oficial_credito in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                   when th1.oficial_credito in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                   when th1.oficial_credito in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                   when th1.oficial_credito in (85,26,83,48) then ('BALCON')
                   when th1.oficial_credito in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                   when th1.oficial_credito in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                   when th1.oficial_credito in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                   else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=th1.oficial_credito) end
             )ASESOR


    FROM(
      SELECT
          MAX(TH.FECHA_INGRESO)FECHA_INGRESO,
          MAX(TH.COD_SOCIO) SOCIO,
          TH.NUMERO_CREDITO,
          TH.OBSERVACIONES OBSERVA,
          MAX(NOMBRE_SOCIO)NOMBRE,
          MAX(TH.GENERO) GENERO,
          MAX(TH.EDAD) EDAD,
          th.codigo_cicn activ,
          MAX(TH.OBS_ACT)OBS_ACT,
          (CASE WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=1 THEN
                                   CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND   5 THEN 'A1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20 THEN 'A2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  65 THEN 'B1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  95 THEN 'B2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'C1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 126 AND 155 THEN 'C2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 156 AND 185 THEN 'D'
                                   ELSE 'E'
                                   END

                                  --CONSUMO
                                  WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=2 THEN
                                   CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5  THEN 'A1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20  THEN 'A2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  50 THEN 'B1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  51 AND  65 THEN 'B2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  80 THEN 'C1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  81 AND  95 THEN 'C2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'D'
                                   ELSE 'E'
                                   END

                                  --VIVIENDA
                                   WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=3 THEN
                                    CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5 THEN 'A1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  35 THEN 'A2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  65 THEN 'A3'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND 120 THEN 'B1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 121 AND 180 THEN 'B2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 181 AND 210 THEN 'C1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 211 AND 270 THEN 'C2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 271 AND 450 THEN 'D'
                                    ELSE 'E'
                                    END

                                   --MICROEMPRESA
                                   WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=4 THEN
                                    CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5  THEN 'A1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20 THEN 'A2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  50 THEN 'B1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  51 AND  65 THEN 'B2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  80 THEN 'C1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  81 AND  95 THEN 'C2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'D'
                                    ELSE 'E'
                                    END
                            END) CALIFICACION,
          /**/
          MAX(TH.CODIGO_PERIOC) CODIGO_PERIOC,
          MAX(TH.NUM_CUOTAS) NUM_CUOTAS,
          max(th.instruccion)instruc,
          max(th.estado_civil)est_civil,
          MAX(TH.CED) CEDULA,
          MAX(TH.NOMBRE_EMPRESA) EMPRESA,
          max(th.cod_telf) telefono,
          max(th.cod_celular) celular,
          MAX(TH.TIPID) TIP_ID,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I') THEN TH.SCAPITAL ELSE 0 END) AS CAP_ACTIVO,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('D') THEN TH.SCAPITAL ELSE 0 END) AS CAP_NDEVENGA,

           --roger
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('E') THEN TH.SCAPITAL ELSE
                   (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
          END) AS CAP_VENCIDO,
          --select * from cred_tabla_amortiza_variable where numero

         -- SUM(CASE WHEN TH.ESTADO_CARSEG IN('E') THEN TH.SCAPITAL ELSE 0 END) AS CAP_VENCIDO,

           SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE
           (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
            END)CAP_SALDO,
          MAX(TH.MONTO_CREDITO) VAL_CREDITO,
          th.of_cred oficial_credito,
          MAX(FECHAINI) FECHA_CONCESION,
          MAX(FECHAFIN) FECHA_VENCIMIENTO,
          MAX(TH.TASA_TEA)TEA,
          MAX(TH.TASA_TIR)TIR,
          MAX(TH.TASA) TASA,
    --    SELECT *FROM CONF_ACTIV_ECO_SOCIO WHERE CODIGO='G474111'

          SUM(TH.DIASMORAPD) DIASMORA_PD,                                       --to_date('05/01/2014','dd/mm/yy')
          (SELECT NVL(SUM(P.CAPITAL),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE('"+fecha.to_date.strftime('%d-%m-%Y')+"','DD/MM/YY'))) AS CAPITAL_CAN,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE 0 END) AS CAPITAL_PEN,
          (
           (SELECT NVL(SUM(P.INTERES),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE('"+fecha.to_date.strftime('%d-%m-%Y')+"','DD/MM/YY')))+
           SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SINTERES ELSE 0 END)
          ) AS INTERES_TOTAL,
          (SELECT NVL(SUM(P.INTERES),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE('"+fecha.to_date.strftime('%d-%m-%Y')+"','DD/MM/YY'))) AS INTERES_CAN,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SINTERES ELSE 0 END) AS INTERES_PEN,
          (SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = TH.COD_GRUPO ) AS NOM_GRUPO,
          (SELECT MIN(DESCRIPCION)  FROM CONF_PRODUCTOS P WHERE P.CODIGO_ACT_FINANCIERA = 2 AND P.CODIGO_GRUPO = TH.COD_GRUPO AND P.CODIGO_PRODUCTO = TH.COD_PRODUCTO) AS NOM_PRODUCTO,
          (SELECT MAX(CCD.MCLI_LUGAR_DIR) FROM SOCIOS_DIRECCIONES CCD WHERE CCD.CODIGO_SOCIO = TH.COD_SOCIO) LUGDIR,
          MAX(TH.COD_ORIREC) ORIGENR, MAX(TH.COD_GRUPORG)GRUPORG,
          (SELECT MIN(SS.DESCRIPCION) FROM SIFV_SUCURSALES SS WHERE SS.CODIGO_SUCURSAL = TH.COD_SUCURSAL) AS SUCURSAL,
          (SELECT MIN(USU_APELLIDOS ||' ' || USU_NOMBRES) FROM SIFV_USUARIOS_SISTEMA SU WHERE SU.CODIGO_USUARIO = TH.COD_USUARIO ) AS NOM_USER,
          (SELECT MIN(USU_APELLIDOS ||' ' || USU_NOMBRES) FROM SIFV_USUARIOS_SISTEMA SU WHERE SU.CODIGO_USUARIO = TH.OF_CRED ) AS NOM_OF_CRE,

       MAX(TH.CODIGO_DESTINO)COD_DESTINO
      FROM(
          SELECT
                 MAX(SDG.SING_FECSOLI) FECHA_INGRESO,
                 CC.NUMERO_CREDITO,
                 CH.ESTADO_CARSEG,
                 COUNT(*) AS CONTADOR,
                 SUM(CH.CAPITAL) AS SCAPITAL,/*------------------*/
                 MAX(cc.num_cuotas) NUM_CUOTAS,
                 COUNT(*) AS NUMCUOTAS,
                 MAX(CC.CODIGO_PERIOC) CODIGO_PERIOC, /**/
                 SUM(CH.INTACT) AS SINTERES, /*------------------*/
                 MAX(CC.TASA_INTERES)AS TASA,
                 (select MAX(TEA) from CRED_REGISTRA_TASA_TIR_TEA T WHERE T.NUMERO_CREDITO = CC.NUMERO_CREDITO )AS TASA_TEA,
                 (select MAX(TIR) from CRED_REGISTRA_TASA_TIR_TEA T WHERE T.NUMERO_CREDITO = CC.NUMERO_CREDITO )AS TASA_TIR,
                 MAX(CH.DIAMORACT)AS DIASMORAPD,
                 SUM(CH.DIAMORACT) AS DIASMORAAC,
                 MAX(S.CODIGO_SOCIO)COD_SOCIO,
                 MAX(S.MCLI_NUMERO_ID)CED,
                 MAX(S.CODIGO_IDENTIFICACION) TIPID,
                 (MAX(S.MCLI_APELLIDO_PAT)||' '||MAX(S.MCLI_APELLIDO_MAT)||' '||MAX(S.MCLI_NOMBRES)) AS NOMBRE_SOCIO,
                 MAX(S.MCLI_RAZON_SOCIAL) AS NOMBRE_EMPRESA,
                 MAX(S.MCLI_SEXO) AS GENERO,
                 MAX(S.MCLI_FECNACI) AS EDAD,
                  /*NATTY*/
                 MAX(S.observacion_profesion) AS OBS_ACT,
                 /**/
                 cc.obs_descre OBSERVACIONES,
                 MAX(CC.MONTO_REAL)MONTO_CREDITO,
                 MAX(CC.FECINI) FECHAINI,
                 MAX(CC.FECFIN) FECHAFIN,
                 MAX(CC.CODIGO_GRUPO) COD_GRUPO,
                 MAX(CC.CODIGO_PRODUCTO) COD_PRODUCTO,
                 MAX(CC.CODIGO_ORIREC) COD_ORIREC,
                 MAX(SDG.CODIGO_GRUPORG) COD_GRUPORG,
                 max(sdg.sing_telefonos) cod_telf,
                 max(sdg.sing_telefono_celular) cod_celular,
                 MAX(CC.CODIGO_SUCURSAL) COD_SUCURSAL,
                 MAX(CC.CODIGO_USUARIO) COD_USUARIO,
                 MAX(CC.OFICRE) OF_CRED,
                 MAX(CC.CODIGO_SUBSECTOR)||MAX(cc.codigo_clasificacion_credito) CODIGO_DESTINO,
                 max(s.codigo_instruccion)instruccion,
                 max(s.codigo_estado_civil)estado_civil,
                 MAX(cc.codigo_clasificacion_credito) CODIGO_CICN   --ACTIVIDAD ECONOMICA
            FROM
                CRED_CREDITOS CC,
                CRED_HISTORIAL_REC_CARTERA CH,
                SOCIOS S,
                SOCIOS_SOLISOC_DATOS_GENERALES SDG
           WHERE CC.NUMERO_CREDITO = CH.NUMERO_CREDITO
             AND S.CODIGO_SOCIO = CC.CODIGO_SOCIO
             AND S.CODIGO_SOCIO = SDG.CODIGO_SOCIO
            AND TRUNC(CH.FGENERA) = TO_DATE('"+ fecha.to_date.strftime('%d-%m-%Y') +"','DD/MM/YY')
            and (case when cc.oficre in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                   when cc.oficre in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                   when cc.oficre in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                   when cc.oficre in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                   when cc.oficre in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                   when cc.oficre in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                   when cc.oficre in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                   when cc.oficre in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                   when cc.oficre in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                   when cc.oficre in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                   when cc.oficre in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                   else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=cc.oficre) end
             ) like upper ('%"+ nombre +"%')
                 GROUP BY CC.NUMERO_CREDITO, CH.ESTADO_CARSEG, CC.OBS_DESCRE
      )TH
       GROUP BY TH.NUMERO_CREDITO, TH.COD_GRUPO, TH.COD_PRODUCTO, TH.OF_CRED, TH.COD_USUARIO, TH.COD_SUCURSAL, TH.COD_SOCIO,TH.OBSERVACIONES,th.codigo_cicn

    ) TH1
    where TH1.DIASMORA_PD between #{diaInicio} and #{diaFin}
    ")


    if results.present?
      return results
    else
      return {}
    end


    data = [{
        socio: '43532',
        credito: '645324',
        provision_requerida: '435.23',
        tipo_garantia: 'Solidaria'
    },{
        socio: '3243',
        credito: '765',
        provision_requerida: '546.35',
        tipo_garantia: 'Real'
    },{
        socio: '234534',
        credito: '456',
        provision_requerida: '234234.2433',
        tipo_garantia: 'Hipoteca'
    },{
        socio: '12898',
        credito: '34523',
        provision_requerida: '43532.23',
        tipo_garantia: 'Solidaria'
    },{
        socio: '9999',
        credito: '89765',
        provision_requerida: '5223.23',
        tipo_garantia: 'Fiduciaria'
    }]
    return data
  end

  def self.obtener_creditos_por_agencia fecha, diaInicio, diaFin

    results = connection.exec_query("
    SELECT TAB.sucursales, COUNT(TAB.CREDITO) NUM_CREDITOS,
    SUM(TAB.MONTO) MONTO_CREDITO,
    SUM(TAB.CAPITAL_NO_DEVENGA) CAP_NDEVENGA,
    SUM(TAB.CAPITAL_VENCIDO) CAP_VENCIDO,
    SUM(TAB.CAPITAL_ACTIVO) CAP_ACTIVO,
    SUM(CARTERA_RIESGO) cartera_afectada,
    SUM(SALDO_CARTERA) SALDO_CARTERA
    FROM (
        SELECT TH1.CREDITO, TH1.MONTO, TH1.SALDO,
              th1.sucursal sucursales, TH1.CAP_ACTIVO CAPITAL_ACTIVO,TH1.CAP_NDEVENGA CAPITAL_NO_DEVENGA, TH1.CAP_VENCIDO CAPITAL_VENCIDO,
              (TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)CARTERA_RIESGO,
              TH1.DIASMORA_PD,
              (TH1.CAP_ACTIVO+TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)SALDO_CARTERA,
              (SELECT SUM(SC.CAPITAL) TCAPITAL  FROM CRED_HISTORIAL_REC_CARTERA SC WHERE TRUNC(SC.FGENERA) = to_date('"+ fecha.to_date.strftime('%d-%m-%Y') +"','dd/mm/yyyy'))AS TSALDO
        FROM(
            SELECT
                TH.NUMERO_CREDITO AS CREDITO, MAX(TH.MON_REAL) MONTO,
                SUM(TH.DIASMORAPD) DIASMORA_PD,
                th.sucursal as sucursal,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('I') THEN TH.SCAPITAL ELSE 0 END) AS CAP_ACTIVO,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('D') THEN TH.SCAPITAL ELSE 0 END) AS CAP_NDEVENGA,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('E') THEN TH.SCAPITAL ELSE
                   (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
                   END) AS CAP_VENCIDO,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE 0 END) AS SALDO
            FROM(
                SELECT CC.NUMERO_CREDITO, CH.ESTADO_CARSEG, MAX(CC.MONTO_REAL) MON_REAL, SUM(CAPITAL) AS SCAPITAL,
                MAX(CH.DIAMORACT)AS DIASMORAPD,
                (select descripcion from sifv_sucursales where cc.codigo_sucursal=codigo_sucursal )sucursal
                  FROM CRED_CREDITOS CC, CRED_HISTORIAL_REC_CARTERA CH
                 WHERE CC.NUMERO_CREDITO = CH.NUMERO_CREDITO
                   AND TRUNC(CH.FGENERA) = to_date('"+ fecha.to_date.strftime('%d-%m-%Y') +"','dd/mm/yyyy')
                 GROUP BY CC.NUMERO_CREDITO, CH.ESTADO_CARSEG,cc.codigo_sucursal
            )TH GROUP BY TH.NUMERO_CREDITO,th.sucursal
        )TH1
        where TH1.DIASMORA_PD between #{diaInicio} and #{diaFin}
    )TAB
    GROUP BY TAB.sucursales
    ORDER BY TAB.sucursales
    ")

    if results.present?
      return results
    else
      return {}
    end

    data = [{
        agencia: 'Matriz',
        cap_activo: 23422.223,
        cap_ndevenga: 234234.5345,
        cap_vencido: 83739.9458,
        cartera_afectada: 943598.3452,
        saldo_cartera: 2393240.0234,
      },{
        agencia: 'Frontera Norte',
        cap_activo: 345345.342,
        cap_ndevenga: 5345.5345,
        cap_vencido: 6542.645,
        cartera_afectada: 6345.2345,
        saldo_cartera: 234634.0234,
      },{
        agencia: 'Servimóvil',
        cap_activo: 23422.223,
        cap_ndevenga: 66576.5345,
        cap_vencido: 9845623.9458,
        cartera_afectada: 546756.745,
        saldo_cartera: 45345.766,
      },{
        agencia: 'Valle Fertil',
        cap_activo: 44562.76,
        cap_ndevenga: 634557.355,
        cap_vencido: 56345.9458,
        cartera_afectada: 456657.3452,
        saldo_cartera: 756876.0234,
      },{
        agencia: 'La Merced',
        cap_activo: 756345.223,
        cap_ndevenga: 45345.5345,
        cap_vencido: 56746.9458,
        cartera_afectada: 67543.3452,
        saldo_cartera: 87456.0234
      }]
    return data
  end


  def self.datos_matriz_transicion fechaInicio, fechaFin, agencia, asesor
    if asesor == " "
      asesor = ""
    end
    if agencia == " "
      agencia = ""
    end

    results = connection.exec_query("
    SELECT
    TH1.SOCIO,
    TH1.NUMERO_CREDITO CREDITO,
    (select MIN(t.tipo_garantia) from seps_historico_c01 t where t.numero_operacion=th1.numero_credito)garantia_vima,

    CASE WHEN TH1.TIP_ID = 'R' THEN TH1.EMPRESA ELSE TH1.NOMBRE END NOMBRE,
    th1.cedula CEDULA,
    round(((sysdate-th1.edad)/360.20),0) EDAD,
    th1.genero GENERO,
    (case th1.est_civil
      when 1 then 'Casado'
      when 2 then 'Soltero'
      when 3 then 'Divorciado'
      when 4 then 'Viudo'
      when 5 then 'Union Libre'
      else 'No Aplica'
      end)
      as ESTADO_CIVIL,
      (select inst_descripcion from socios_instruccion where inst_codigo = th1.instruc) nivel_de_instruccion,
    th1.CALIFICACION_INICIAL,
    TH1.CALIFICACION_FINAL,
    TH1.CAP_SALDO,
    TH1.DIASMORA_PD,
    TH1.NOM_GRUPO,

    (SELECT descripcion FROM CRED_ACT_ECO_DEST_CRE A WHERE A.CODIGO =TH1.activ AND A.NIVEL=5)DESTINO_CREDITO,
    TH1.CODIGO_PERIOC,
    (TH1.NUM_CUOTAS) AS CUOTAS_CREDITO,
    (select count(*) from cred_tabla_amortiza_variable where estadocal='P' and numero_credito=th1.numero_credito) as cuotas_p,
    (case when (select count(*) from cred_tabla_amortiza_variable where estadocal in ('C') and numero_credito=th1.numero_credito)=0 then 1
    else (select max(rownum)+1 from cred_tabla_amortiza_variable ct where estadocal='C' and numero_credito=th1.numero_credito) end
    )cuota_vencida,
    TH1.CAP_SALDO,
    TH1.VAL_CREDITO,
    TH1.CAP_ACTIVO,
    TH1.CAP_NDEVENGA,
    TH1.CAP_VENCIDO,
    (TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)CARTERA_RIESGO,
    (select min(j.fecinical) from cred_tabla_amortiza_variable j
    where j.ordencal = (select min(i.ordencal)  from cred_tabla_amortiza_variable i
                        where i.numero_credito = TH1.NUMERO_CREDITO)
      and j.numero_credito = TH1.NUMERO_CREDITO) as FECHA_CONCESION,
    (select max(j.fecfincal) from cred_tabla_amortiza_variable j
    where j.ordencal = (select max(i.ordencal)  from cred_tabla_amortiza_variable i
                        where i.numero_credito = TH1.NUMERO_CREDITO)
      and j.numero_credito = TH1.NUMERO_CREDITO) as FECHA_VENCIMIENTO,
    (select SUM(ROUND(NVL(CAPITALCAL,0),2) + ROUND(NVL(INTERESCAL,0),2) + ROUND(NVL(MORACAL,0),2) +
              ROUND(CASE WHEN trunc(fecinical)>trunc(sysdate) THEN 0 ELSE NVL(rubroscal,0) END,2)) from CRED_TABLA_AMORTIZA_VARIABLE A
                         where a.numero_credito=TH1.numero_credito
                         and estadocal='P')valor_cancela,
    TH1.TASA,
    TH1.DIASMORA_PD,
    TH1.SUCURSAL OFICINA,
    TH1.NOM_OF_CRE CARTERA_HEREDADA,
             (case when th1.oficial_credito in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                   when th1.oficial_credito in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                   when th1.oficial_credito in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                   when th1.oficial_credito in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                   when th1.oficial_credito in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                   when th1.oficial_credito in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                   when th1.oficial_credito in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                   when th1.oficial_credito in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                   when th1.oficial_credito in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                   when th1.oficial_credito in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                   when th1.oficial_credito in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                   else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=th1.oficial_credito) end
             )ASESOR,
    (SELECT max(DS.TIPO_SECTOR)
        FROM SOCIOS_DIRECCIONES DS WHERE TH1.SOCIO = DS.CODIGO_SOCIO
        AND DS.FECHA_INGRESO = (SELECT MAX(X.FECHA_INGRESO) FROM SOCIOS_DIRECCIONES X WHERE X.CODIGO_SOCIO = TH1.SOCIO)
    )AS SECTOR,
    (
     SELECT MAX(DESCRIPCION) from Sifv_Parroquias d
       WHERE d.codigo_pais = substr(TH1.LUGDIR,1,2)
         and d.codigo_provincia = substr(TH1.LUGDIR,3,2)
         and d.codigo_ciudad = substr(TH1.LUGDIR,5,2)
         and d.codigo_parroquia = substr(TH1.LUGDIR,7,2)
    ) AS PARROQUIA,
    (
     SELECT MAX(DESCRIPCION) from Sifv_Ciudades d
       WHERE d.codigo_pais = substr(TH1.LUGDIR,1,2)
         and d.codigo_provincia = substr(TH1.LUGDIR,3,2)
         and d.codigo_ciudad = substr(TH1.LUGDIR,5,2)
    ) AS CANTON,
    (
     SELECT MAX(DESCRIPCION) FROM SIFV_PROVINCIA D
       WHERE D.CODIGO_PAIS = substr(TH1.LUGDIR,1,2)
         AND D.CODIGO_PROVINCIA = substr(TH1.LUGDIR,3,2)
    )AS PROVINCIA
    FROM(
      SELECT
          MAX(TH.FECHA_INGRESO)FECHA_INGRESO,
          MAX(TH.COD_SOCIO) SOCIO,
          TH.NUMERO_CREDITO,
          TH.OBSERVACIONES OBSERVA,
          MAX(NOMBRE_SOCIO)NOMBRE,
          MAX(TH.GENERO) GENERO,
          MAX(TH.EDAD) EDAD,
          th.codigo_cicn activ,
          /**/
          MAX(TH.OBS_ACT)OBS_ACT,
          (CASE WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=1 THEN
                                   CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND   5 THEN 'A1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20 THEN 'A2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  65 THEN 'B1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  95 THEN 'B2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'C1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 126 AND 155 THEN 'C2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 156 AND 185 THEN 'D'
                                   ELSE 'E'
                                   END

                                  --CONSUMO
                                  WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=2 THEN
                                   CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5  THEN 'A1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20  THEN 'A2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  50 THEN 'B1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  51 AND  65 THEN 'B2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  80 THEN 'C1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  81 AND  95 THEN 'C2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'D'
                                   ELSE 'E'
                                   END

                                  --VIVIENDA
                                   WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=3 THEN
                                    CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5 THEN 'A1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  35 THEN 'A2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  65 THEN 'A3'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND 120 THEN 'B1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 121 AND 180 THEN 'B2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 181 AND 210 THEN 'C1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 211 AND 270 THEN 'C2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 271 AND 450 THEN 'D'
                                    ELSE 'E'
                                    END
                                   --MICROEMPRESA
                                   WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=4 THEN
                                    CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5  THEN 'A1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20 THEN 'A2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  50 THEN 'B1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  51 AND  65 THEN 'B2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  80 THEN 'C1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  81 AND  95 THEN 'C2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'D'
                                    ELSE 'E'
                                    END
                            END) CALIFICACION_FINAL,

                            (CASE WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO cg WHERE cg.CODIGO_GRUPO=TH.COD_GRUPO))=1 THEN
                                   CASE WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN   0 AND   5 THEN 'A1'
                                        WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN   6 AND  20 THEN 'A2'
                                        WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  21 AND  35 THEN 'A3'
                                        WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  36 AND  65 THEN 'B1'
                                        WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  66 AND  95 THEN 'B2'
                                        WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  96 AND 125 THEN 'C1'
                                        WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN 126 AND 155 THEN 'C2'
                                        WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN 156 AND 185 THEN 'D'
                                   ELSE 'E'
                                   END
                                  --CONSUMO
                                  WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=2 THEN
                                   CASE WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN   0 AND  5  THEN 'A1'
                                        WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN   6 AND  20  THEN 'A2'
                                        WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  21 AND  35 THEN 'A3'
                                        WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  36 AND  50 THEN 'B1'
                                        WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  51 AND  65 THEN 'B2'
                                        WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  66 AND  80 THEN 'C1'
                                        WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  81 AND  95 THEN 'C2'
                                        WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  96 AND 125 THEN 'D'
                                   ELSE 'E'
                                   END
                                  --VIVIENDA
                                   WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=3 THEN
                                    CASE WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN   0 AND  5 THEN 'A1'
                                         WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN   6 AND  35 THEN 'A2'
                                         WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  36 AND  65 THEN 'A3'
                                         WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  66 AND 120 THEN 'B1'
                                         WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN 121 AND 180 THEN 'B2'
                                         WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN 181 AND 210 THEN 'C1'
                                         WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN 211 AND 270 THEN 'C2'
                                         WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN 271 AND 450 THEN 'D'
                                    ELSE 'E'
                                    END
                                   --MICROEMPRESA
                                   WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=4 THEN
                                    CASE WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN   0 AND  5  THEN 'A1'
                                         WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN   6 AND  20 THEN 'A2'
                                         WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  21 AND  35 THEN 'A3'
                                         WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  36 AND  50 THEN 'B1'
                                         WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  51 AND  65 THEN 'B2'
                                         WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  66 AND  80 THEN 'C1'
                                         WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  81 AND  95 THEN 'C2'
                                         WHEN nvl((select max(diamoract) from CRED_HISTORIAL_REC_CARTERA where TRUNC(FGENERA)=TO_DATE('#{fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
                                   and NUMERO_CREDITO=TH.NUMERO_CREDITO),0) BETWEEN  96 AND 125 THEN 'D'
                                    ELSE 'E'
                                    END
                            END) CALIFICACION_INICIAL,
          MAX(TH.CODIGO_PERIOC) CODIGO_PERIOC,
          MAX(TH.NUM_CUOTAS) NUM_CUOTAS,
          max(th.instruccion)instruc,
          max(th.estado_civil)est_civil,
          MAX(TH.CED) CEDULA,
          MAX(TH.NOMBRE_EMPRESA) EMPRESA,
          max(th.cod_telf) telefono,
          max(th.cod_celular) celular,
          MAX(TH.TIPID) TIP_ID,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I') THEN TH.SCAPITAL ELSE 0 END) AS CAP_ACTIVO,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('D') THEN TH.SCAPITAL ELSE 0 END) AS CAP_NDEVENGA,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('E') THEN TH.SCAPITAL ELSE
                   (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
          END) AS CAP_VENCIDO,
           SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE
           (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
            END)CAP_SALDO,
          MAX(TH.MONTO_CREDITO) VAL_CREDITO,
          th.of_cred oficial_credito,
          MAX(FECHAINI) FECHA_CONCESION,
          MAX(FECHAFIN) FECHA_VENCIMIENTO,
          MAX(TH.TASA_TEA)TEA,
          MAX(TH.TASA_TIR)TIR,
          MAX(TH.TASA) TASA,
          SUM(TH.DIASMORAPD) DIASMORA_PD,
          (SELECT NVL(SUM(P.CAPITAL),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE('#{fechaFin.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY'))) AS CAPITAL_CAN,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE 0 END) AS CAPITAL_PEN,
          (
           (SELECT NVL(SUM(P.INTERES),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE('#{fechaFin.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')))+
           SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SINTERES ELSE 0 END)
          ) AS INTERES_TOTAL,
          (SELECT NVL(SUM(P.INTERES),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE('#{fechaFin.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY'))) AS INTERES_CAN,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SINTERES ELSE 0 END) AS INTERES_PEN,
          (SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = TH.COD_GRUPO ) AS NOM_GRUPO,
          (SELECT MIN(DESCRIPCION)  FROM CONF_PRODUCTOS P WHERE P.CODIGO_ACT_FINANCIERA = 2 AND P.CODIGO_GRUPO = TH.COD_GRUPO AND P.CODIGO_PRODUCTO = TH.COD_PRODUCTO) AS NOM_PRODUCTO,
          (SELECT MAX(CCD.MCLI_LUGAR_DIR) FROM SOCIOS_DIRECCIONES CCD WHERE CCD.CODIGO_SOCIO = TH.COD_SOCIO) LUGDIR,
          MAX(TH.COD_ORIREC) ORIGENR, MAX(TH.COD_GRUPORG)GRUPORG,
          (SELECT MIN(SS.DESCRIPCION) FROM SIFV_SUCURSALES SS WHERE SS.CODIGO_SUCURSAL = TH.COD_SUCURSAL) AS SUCURSAL,
          (SELECT MIN(USU_APELLIDOS ||' ' || USU_NOMBRES) FROM SIFV_USUARIOS_SISTEMA SU WHERE SU.CODIGO_USUARIO = TH.COD_USUARIO ) AS NOM_USER,
          (SELECT MIN(USU_APELLIDOS ||' ' || USU_NOMBRES) FROM SIFV_USUARIOS_SISTEMA SU WHERE SU.CODIGO_USUARIO = TH.OF_CRED ) AS NOM_OF_CRE,
       MAX(TH.CODIGO_DESTINO)COD_DESTINO
      FROM(
          SELECT
                 MAX(SDG.SING_FECSOLI) FECHA_INGRESO,
                 CC.NUMERO_CREDITO,
                 CH.ESTADO_CARSEG,
                 COUNT(*) AS CONTADOR,
                 SUM(CH.CAPITAL) AS SCAPITAL,
                 MAX(cc.num_cuotas) NUM_CUOTAS,
                 COUNT(*) AS NUMCUOTAS,
                 MAX(CC.CODIGO_PERIOC) CODIGO_PERIOC,
                 SUM(CH.INTACT) AS SINTERES,
                 MAX(CC.TASA_INTERES)AS TASA,
                 (select MAX(TEA) from CRED_REGISTRA_TASA_TIR_TEA T WHERE T.NUMERO_CREDITO = CC.NUMERO_CREDITO )AS TASA_TEA,
                 (select MAX(TIR) from CRED_REGISTRA_TASA_TIR_TEA T WHERE T.NUMERO_CREDITO = CC.NUMERO_CREDITO )AS TASA_TIR,
                 MAX(CH.DIAMORACT)AS DIASMORAPD,
                 SUM(CH.DIAMORACT) AS DIASMORAAC,
                 MAX(S.CODIGO_SOCIO)COD_SOCIO,
                 MAX(S.MCLI_NUMERO_ID)CED,
                 MAX(S.CODIGO_IDENTIFICACION) TIPID,
                 (MAX(S.MCLI_APELLIDO_PAT)||' '||MAX(S.MCLI_APELLIDO_MAT)||' '||MAX(S.MCLI_NOMBRES)) AS NOMBRE_SOCIO,
                 MAX(S.MCLI_RAZON_SOCIAL) AS NOMBRE_EMPRESA,
                 MAX(S.MCLI_SEXO) AS GENERO,
                 MAX(S.MCLI_FECNACI) AS EDAD,
                 MAX(S.observacion_profesion) AS OBS_ACT,
                 cc.obs_descre OBSERVACIONES,
                 MAX(CC.MONTO_REAL)MONTO_CREDITO,
                 MAX(CC.FECINI) FECHAINI,
                 MAX(CC.FECFIN) FECHAFIN,
                 MAX(CC.CODIGO_GRUPO) COD_GRUPO,
                 MAX(CC.CODIGO_PRODUCTO) COD_PRODUCTO,
                 MAX(CC.CODIGO_ORIREC) COD_ORIREC,
                 MAX(SDG.CODIGO_GRUPORG) COD_GRUPORG,
                 max(sdg.sing_telefonos) cod_telf,
                 max(sdg.sing_telefono_celular) cod_celular,
                 MAX(CC.CODIGO_SUCURSAL) COD_SUCURSAL,
                 MAX(CC.CODIGO_USUARIO) COD_USUARIO,
                 MAX(CC.OFICRE) OF_CRED,
                 MAX(CC.CODIGO_SUBSECTOR)||MAX(cc.codigo_clasificacion_credito) CODIGO_DESTINO,
                 max(s.codigo_instruccion)instruccion,
                 max(s.codigo_estado_civil)estado_civil,
                 MAX(cc.codigo_clasificacion_credito) CODIGO_CICN
            FROM
                CRED_CREDITOS CC,
                CRED_HISTORIAL_REC_CARTERA CH,
                SOCIOS S,
                SOCIOS_SOLISOC_DATOS_GENERALES SDG
           WHERE CC.NUMERO_CREDITO = CH.NUMERO_CREDITO
             AND S.CODIGO_SOCIO = CC.CODIGO_SOCIO
             AND S.CODIGO_SOCIO = SDG.CODIGO_SOCIO

             and cc.fecha_credito<=TO_DATE('#{fechaFin.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
            AND TRUNC(CH.FGENERA) = TO_DATE('#{fechaFin.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
            and (case when CC.OFICRE in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                   when CC.OFICRE in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                   when CC.OFICRE in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                   when CC.OFICRE in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                   when CC.OFICRE in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                   when CC.OFICRE in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                   when CC.OFICRE in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                   when CC.OFICRE in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                   when CC.OFICRE in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                   when CC.OFICRE in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                   when CC.OFICRE in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                   else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=CC.OFICRE) end
             )like upper ('%#{asesor}%')
             AND (SELECT MIN(SS.DESCRIPCION) FROM SIFV_SUCURSALES SS WHERE SS.CODIGO_SUCURSAL = CC.CODIGO_SUCURSAL) LIKE ('%#{agencia}%')
            GROUP BY CC.NUMERO_CREDITO, CH.ESTADO_CARSEG, CC.OBS_DESCRE
      )TH
       GROUP BY TH.NUMERO_CREDITO, TH.COD_GRUPO, TH.COD_PRODUCTO, TH.OF_CRED, TH.COD_USUARIO, TH.COD_SUCURSAL, TH.COD_SOCIO,TH.OBSERVACIONES,th.codigo_cicn
    ) TH1
    ")

    if results.present?
      return results
    else
      return {}
    end


    data = [{
        credito: 17654,
        socio: 23423,
        saldo: 4000,
        nombre: 'Santiago Lopez',
        calificacion_inicial: 'A1',
        calificacion_final: 'A1',
        cap_saldo: '2342.345',
        diasmora_pd: 324,
        liquidador: 'Santy L',
        cartera_heredada: 'Valentina',
        agencia: 'Matriz',
        of_cred: 'Daniela'
    },{
        credito: 234,
        socio: 867,
        saldo: 4000,
        nombre: 'Ivan Aguirre',
        calificacion_inicial: 'E',
        calificacion_final: 'E',
        cap_saldo: '7542.3345',
        diasmora_pd: 90,
        liquidador: 'Santy L',
        cartera_heredada: 'Andrea',
        agencia: 'La Merced',
        of_cred: 'Sofia'
    },{
        credito: 17345654,
        socio: 7585,
        saldo: 4000,
        nombre: 'Tatiana Lopez',
        calificacion_inicial: 'A1',
        calificacion_final: 'A3',
        cap_saldo: '56345.345',
        diasmora_pd: 324,
        liquidador: 'Santy L',
        cartera_heredada: 'Josefina',
        agencia: 'Servimovil',
        of_cred: 'Andrea'
    },{
        credito: 4564,
        socio: 765,
        saldo: 567745.985,
        nombre: 'Isabella Lopez',
        calificacion_inicial: 'B2',
        calificacion_final: 'E',
        cap_saldo: '5435.324',
        diasmora_pd: 324,
        liquidador: 'Santy L',
        cartera_heredada: 'Daniela Calderon',
        agencia: 'Matriz',
        of_cred: 'Daniela'
    },{
        credito: 456,
        socio: 7423,
        saldo: 56786.657,
        nombre: 'Isabella Lopez',
        calificacion_inicial: 'A2',
        calificacion_final: 'A1',
        cap_saldo: '2342.345',
        diasmora_pd: 724,
        liquidador: 'Santy L',
        cartera_heredada: 'Valentina',
        agencia: 'Matriz',
        of_cred: 'Daniela'
    },{
        credito: 5673,
        socio: 345475,
        saldo: 5674.345,
        nombre: 'Isabella Lopez',
        calificacion_inicial: 'D',
        calificacion_final: 'E',
        cap_saldo: '9875.345',
        diasmora_pd: 324,
        liquidador: 'Santy L',
        cartera_heredada: 'Valentina',
        agencia: 'La Merced',
        of_cred: 'Paola'
    },{
        credito: 645234,
        socio: 345,
        saldo: 5463.45,
        nombre: 'Isabella Lopez',
        calificacion_inicial: 'A2',
        calificacion_final: 'A3',
        cap_saldo: '576.345',
        diasmora_pd: 334,
        liquidador: 'Nicole L',
        cartera_heredada: 'Tatiana',
        agencia: 'Matriz',
        of_cred: 'Selena'
    },{
        credito: 345345,
        socio: 4568,
        saldo: 546.4564,
        nombre: 'Santiago Lopez',
        calificacion_inicial: 'A1',
        calificacion_final: 'A1',
        cap_saldo: '6000.345',
        diasmora_pd: 324,
        liquidador: 'Stefania L',
        cartera_heredada: 'Lorena',
        agencia: 'Matriz',
        of_cred: 'Sofia'
    },{
        credito: 556,
        socio: 3345,
        saldo: 1000,
        nombre: 'Santy Xavier',
        calificacion_inicial: 'B2',
        calificacion_final: 'B1',
        cap_saldo: '1000',
        diasmora_pd: 324,
        liquidador: 'Lorena C.',
        cartera_heredada: 'Lorena',
        agencia: 'Matriz',
        of_cred: 'Sofia'
    }]

    return data;
  end


  def self.obtener_creditos_concedidos_por_agencia fechaInicio, fechaFin, diaInicio, diaFin
    results = connection.exec_query("
    SELECT TAB.sucursales, COUNT(TAB.CREDITO) NUM_CREDITOS,
    SUM(TAB.MONTO) MONTO_CREDITO,
    SUM(TAB.CAPITAL_NO_DEVENGA) CAP_NDEVENGA,
    SUM(TAB.CAPITAL_VENCIDO) CAP_VENCIDO,
    SUM(TAB.CAPITAL_ACTIVO) CAP_ACTIVO,
    SUM(CARTERA_RIESGO) CARTERA_AFECTADA,
    SUM(SALDO_CARTERA) SALDO_CARTERA
    FROM (
        SELECT TH1.CREDITO, TH1.MONTO, TH1.SALDO,
              th1.sucursal sucursales, TH1.CAP_ACTIVO CAPITAL_ACTIVO,TH1.CAP_NDEVENGA CAPITAL_NO_DEVENGA, TH1.CAP_VENCIDO CAPITAL_VENCIDO,
              (TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)CARTERA_RIESGO,
              TH1.DIASMORA_PD,
              (TH1.CAP_ACTIVO+TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)SALDO_CARTERA,
              (SELECT SUM(SC.CAPITAL) TCAPITAL  FROM CRED_HISTORIAL_REC_CARTERA SC WHERE TRUNC(SC.FGENERA) = to_date('#{ fechaFin.to_date.strftime('%d-%m-%Y') }','dd/mm/yyyy'))AS TSALDO
        FROM(
            SELECT
                TH.NUMERO_CREDITO AS CREDITO, MAX(TH.MON_REAL) MONTO,
                SUM(TH.DIASMORAPD) DIASMORA_PD,
                th.sucursal as sucursal,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('I') THEN TH.SCAPITAL ELSE 0 END) AS CAP_ACTIVO,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('D') THEN TH.SCAPITAL ELSE 0 END) AS CAP_NDEVENGA,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('E') THEN TH.SCAPITAL ELSE
                   (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
                   END) AS CAP_VENCIDO,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE 0 END) AS SALDO
            FROM(
                SELECT CC.NUMERO_CREDITO, CH.ESTADO_CARSEG, MAX(CC.MONTO_REAL) MON_REAL, SUM(CAPITAL) AS SCAPITAL,
                MAX(CH.DIAMORACT)AS DIASMORAPD,
                (select descripcion from sifv_sucursales where cc.codigo_sucursal=codigo_sucursal )sucursal
                  FROM CRED_CREDITOS CC, CRED_HISTORIAL_REC_CARTERA CH
                 WHERE CC.NUMERO_CREDITO = CH.NUMERO_CREDITO
                   AND TRUNC(CH.FGENERA) = to_date('#{ fechaFin.to_date.strftime('%d-%m-%Y') }','dd/mm/yyyy')
                    and cc.fecha_credito between TO_DATE('#{ fechaInicio.to_date.strftime('%d-%m-%Y') }','DD/MM/YY') and TO_DATE('#{ fechaFin.to_date.strftime('%d-%m-%Y') }','DD/MM/YY')
                 GROUP BY CC.NUMERO_CREDITO, CH.ESTADO_CARSEG,cc.codigo_sucursal
            )TH GROUP BY TH.NUMERO_CREDITO,th.sucursal
        )TH1
    where TH1.DIASMORA_PD between #{diaInicio} and #{diaFin}
    )TAB
    GROUP BY TAB.sucursales
    ORDER BY TAB.sucursales")
    if results.present?
      return results
    else
      return {}
    end
    data = [{
        sucursales: 'Matriz',
        num_creditos: 4,
        cap_activo: 23422.223,
        cap_ndevenga: 234234.5345,
        cap_vencido: 83739.9458,
        cartera_afectada: 943598.3452,
        saldo_cartera: 2393240.0234,
    },{
        sucursales: 'Frontera Norte',
        num_creditos: 12,
        cap_activo: 345345.342,
        cap_ndevenga: 5345.5345,
        cap_vencido: 6542.645,
        cartera_afectada: 6345.2345,
        saldo_cartera: 234634.0234,
    },{
        sucursales: 'Servimóvil',
        num_creditos: 6,
        cap_activo: 23422.223,
        cap_ndevenga: 66576.5345,
        cap_vencido: 9845623.9458,
        cartera_afectada: 546756.745,
        saldo_cartera: 45345.766,
    },{
        sucursales: 'Valle Fertil',
        num_creditos: 34,
        cap_activo: 44562.76,
        cap_ndevenga: 634557.355,
        cap_vencido: 56345.9458,
        cartera_afectada: 456657.3452,
        saldo_cartera: 756876.0234,
    },{
        sucursales: 'La Merced',
        num_creditos: 75,
        cap_activo: 756345.223,
        cap_ndevenga: 45345.5345,
        cap_vencido: 56746.9458,
        cartera_afectada: 67543.3452,
        saldo_cartera: 87456.0234
    }]
    return data
  end

  def self.obtener_creditos_concedidos_por_asesor fechaInicio, fechaFin, diaInicio, diaFin
    results = connection.exec_query("
    SELECT TAB.ASESORES, COUNT(TAB.CREDITO) NUM_CREDITOS,
    SUM(TAB.MONTO) MONTO_CREDITO,
    SUM(TAB.CAPITAL_NO_DEVENGA) CAP_NDEVENGA,
    SUM(TAB.CAPITAL_VENCIDO) CAP_VENCIDO,
    SUM(TAB.CAPITAL_ACTIVO) CAP_ACTIVO,
    SUM(CARTERA_RIESGO) cartera_afectada,
    SUM(SALDO_CARTERA) SALDO_CARTERA
    FROM (
        SELECT TH1.CREDITO, TH1.MONTO, TH1.SALDO,
              th1.asesor ASESORES, TH1.CAP_ACTIVO CAPITAL_ACTIVO,TH1.CAP_NDEVENGA CAPITAL_NO_DEVENGA, TH1.CAP_VENCIDO CAPITAL_VENCIDO,
              (TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)CARTERA_RIESGO,
              TH1.DIASMORA_PD,
              (TH1.CAP_ACTIVO+TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)SALDO_CARTERA,
              (SELECT SUM(SC.CAPITAL) TCAPITAL  FROM CRED_HISTORIAL_REC_CARTERA SC WHERE TRUNC(SC.FGENERA) = to_date('#{ fechaFin.to_date.strftime('%d-%m-%Y') }','dd/mm/yyyy'))AS TSALDO
        FROM(
            SELECT
                TH.NUMERO_CREDITO AS CREDITO, MAX(TH.MON_REAL) MONTO,th.asesor asesor,
                SUM(TH.DIASMORAPD) DIASMORA_PD,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('I') THEN TH.SCAPITAL ELSE 0 END) AS CAP_ACTIVO,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('D') THEN TH.SCAPITAL ELSE 0 END) AS CAP_NDEVENGA,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('E') THEN TH.SCAPITAL ELSE
                   (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
                   END) AS CAP_VENCIDO,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE 0 END) AS SALDO
            FROM(
                SELECT CC.NUMERO_CREDITO, CH.ESTADO_CARSEG, MAX(CC.MONTO_REAL) MON_REAL, SUM(CAPITAL) AS SCAPITAL,
                MAX(CH.DIAMORACT)AS DIASMORAPD,
                (case when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                   else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=(select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO)) end
             )asesor
                  FROM CRED_CREDITOS CC, CRED_HISTORIAL_REC_CARTERA CH
                 WHERE CC.NUMERO_CREDITO = CH.NUMERO_CREDITO
                   AND TRUNC(CH.FGENERA) = to_date('#{ fechaFin.to_date.strftime('%d-%m-%Y') }','dd/mm/yyyy')
                    and cc.fecha_credito between TO_DATE('#{ fechaInicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YY') and TO_DATE('#{ fechaFin.to_date.strftime('%d-%m-%Y') }','DD/MM/YY')

                 GROUP BY CC.NUMERO_CREDITO, CH.ESTADO_CARSEG
            )TH GROUP BY TH.NUMERO_CREDITO,th.asesor
        )TH1
    where TH1.DIASMORA_PD between #{diaInicio} and #{diaFin}
    )TAB
    GROUP BY TAB.ASESORES
    ORDER BY TAB.ASESORES
    ")
    if results.present?
      return results
    else
      return {}
    end
    data = [{
        asesores: 'Santiago Lopez',
        cap_activo: 23422.223,
        cap_ndevenga: 234234.5345,
        cap_vencido: 83739.9458,
        cartera_afectada: 943598.3452,
        saldo_cartera: 2393240.0234,
    },{
        asesores: 'Chlor Wrigth',
        cap_activo: 23422.223,
        cap_ndevenga: 234234.5345,
        cap_vencido: 83739.9458,
        cartera_afectada: 943598.3452,
        saldo_cartera: 2393240.0234,
    },{
        asesores: 'Daniela Ruiz',
        cap_activo: 23422.223,
        cap_ndevenga: 234234.5345,
        cap_vencido: 83739.9458,
        cartera_afectada: 943598.3452,
        saldo_cartera: 2393240.0234,
    },{
        asesores: 'Sofia Guerra',
        cap_activo: 23422.223,
        cap_ndevenga: 234234.5345,
        cap_vencido: 83739.9458,
        cartera_afectada: 943598.3452,
        saldo_cartera: 2393240.0234,
    },{
        asesores: 'Valentina Amador',
        cap_activo: 23422.223,
        cap_ndevenga: 234234.5345,
        cap_vencido: 83739.9458,
        cartera_afectada: 943598.3452,
        saldo_cartera: 2393240.0234
    }]
    return data
  end

  def self.obtener_saldo_cartera_agencia fecha
    results = connection.exec_query("
    SELECT TAB.sucursales,
    SUM(SALDO_CARTERA) SALDO_CARTERA
    FROM (
        SELECT TH1.CREDITO, TH1.MONTO, TH1.SALDO,
              th1.sucursal sucursales, TH1.CAP_ACTIVO CAPITAL_ACTIVO,TH1.CAP_NDEVENGA CAPITAL_NO_DEVENGA, TH1.CAP_VENCIDO CAPITAL_VENCIDO,
              (TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)CARTERA_RIESGO,
              TH1.DIASMORA_PD,
              (TH1.CAP_ACTIVO+TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)SALDO_CARTERA,
              (SELECT SUM(SC.CAPITAL) TCAPITAL  FROM CRED_HISTORIAL_REC_CARTERA SC WHERE TRUNC(SC.FGENERA) = to_date('#{fecha.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy'))AS TSALDO
        FROM(
            SELECT
                TH.NUMERO_CREDITO AS CREDITO, MAX(TH.MON_REAL) MONTO,
                SUM(TH.DIASMORAPD) DIASMORA_PD,
                th.sucursal as sucursal,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('I') THEN TH.SCAPITAL ELSE 0 END) AS CAP_ACTIVO,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('D') THEN TH.SCAPITAL ELSE 0 END) AS CAP_NDEVENGA,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('E') THEN TH.SCAPITAL ELSE
                   (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
                   END) AS CAP_VENCIDO,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE 0 END) AS SALDO
            FROM(
                SELECT CC.NUMERO_CREDITO, CH.ESTADO_CARSEG, MAX(CC.MONTO_REAL) MON_REAL, SUM(CAPITAL) AS SCAPITAL,
                MAX(CH.DIAMORACT)AS DIASMORAPD,
                (select descripcion from sifv_sucursales where cc.codigo_sucursal=codigo_sucursal )sucursal
                  FROM CRED_CREDITOS CC, CRED_HISTORIAL_REC_CARTERA CH
                 WHERE CC.NUMERO_CREDITO = CH.NUMERO_CREDITO
                   AND TRUNC(CH.FGENERA) = to_date('#{fecha.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                 GROUP BY CC.NUMERO_CREDITO, CH.ESTADO_CARSEG,cc.codigo_sucursal
            )TH GROUP BY TH.NUMERO_CREDITO,th.sucursal
        )TH1
    )TAB
    GROUP BY TAB.sucursales
    ORDER BY TAB.sucursales
    ")

    if results.present?
      return results
    else
      return {}
    end
  end


  def self.obtener_saldo_cartera_asesor fecha
    results = connection.exec_query("
    SELECT TAB.ASESORES,
    SUM(SALDO_CARTERA) SALDO_CARTERA
    FROM (
        SELECT TH1.CREDITO, TH1.MONTO, TH1.SALDO,
              th1.asesor ASESORES, TH1.CAP_ACTIVO CAPITAL_ACTIVO,TH1.CAP_NDEVENGA CAPITAL_NO_DEVENGA, TH1.CAP_VENCIDO CAPITAL_VENCIDO,
              (TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)CARTERA_RIESGO,
              TH1.DIASMORA_PD,
              (TH1.CAP_ACTIVO+TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)SALDO_CARTERA,
              (SELECT SUM(SC.CAPITAL) TCAPITAL  FROM CRED_HISTORIAL_REC_CARTERA SC WHERE TRUNC(SC.FGENERA) = to_date('#{ fecha.to_date.strftime('%d-%m-%Y') }','dd/mm/yyyy'))AS TSALDO
        FROM(
            SELECT
                TH.NUMERO_CREDITO AS CREDITO, MAX(TH.MON_REAL) MONTO,th.asesor asesor,
                SUM(TH.DIASMORAPD) DIASMORA_PD,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('I') THEN TH.SCAPITAL ELSE 0 END) AS CAP_ACTIVO,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('D') THEN TH.SCAPITAL ELSE 0 END) AS CAP_NDEVENGA,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('E') THEN TH.SCAPITAL ELSE
                   (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
                   END) AS CAP_VENCIDO,
                SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE 0 END) AS SALDO
            FROM(
                SELECT CC.NUMERO_CREDITO, CH.ESTADO_CARSEG, MAX(CC.MONTO_REAL) MON_REAL, SUM(CAPITAL) AS SCAPITAL,
                MAX(CH.DIAMORACT)AS DIASMORAPD,
                (case when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                   when (select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO) in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                   else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=(select c.oficre from cred_creditos c where c.numero_credito=CC.NUMERO_CREDITO)) end
             )asesor
                  FROM CRED_CREDITOS CC, CRED_HISTORIAL_REC_CARTERA CH
                  WHERE CC.NUMERO_CREDITO = CH.NUMERO_CREDITO
                   AND TRUNC(CH.FGENERA) = to_date('#{fecha.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                 GROUP BY CC.NUMERO_CREDITO, CH.ESTADO_CARSEG
            )TH GROUP BY TH.NUMERO_CREDITO,th.asesor
        )TH1
    )TAB
    GROUP BY TAB.ASESORES
    ORDER BY TAB.ASESORES
    ")

    if results.present?
      return results
    else
      return {}
    end
  end

  def self.obtener_creditos_concedidos_de_un_asesor asesor, fechaInicio, fechaFin, diaInicio, diaFin

    results = connection.exec_query("
    SELECT
    TH1.FECHA_INGRESO FECHA_INGRESO,
    (select MAX(descripcion) from cred_tipos_recursos_economicos where codigo = TH1.ORIGENR) as ORIGEN_RECURSOS,
    TH1.SOCIO,
    TH1.NUMERO_CREDITO CREDITO,
    (select tt.provision_especifica from temp_c02 tt where tt.numero_operacion=th1.numero_credito)provision_requerida,
    TH1.CODIGO_PERIOC,
    (TH1.NUM_CUOTAS) AS CUOTAS_CREDITO,
    CASE WHEN TH1.TIP_ID = 'R' THEN TH1.EMPRESA ELSE TH1.NOMBRE END NOMBRE,
    TH1.TIP_ID,
    TH1.CEDULA,
    TH1.GENERO GENERO,
    TRUNC((SYSDATE-TH1.EDAD)/365.25)EDAD,
    th1.edad fecha_nacimiento,

    TH1.CALIFICACION,
    TH1.CAP_ACTIVO,
    TH1.CAP_NDEVENGA,
    TH1.CAP_VENCIDO,
    (TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)CARTERA_RIESGO,
    (TH1.CAP_ACTIVO+
    TH1.CAP_NDEVENGA+
    TH1.CAP_VENCIDO)saldo_cartera,

    /*FECHA CONCESION*/
    (select min(j.fecinical) from cred_tabla_amortiza_variable j
    where j.ordencal = (select min(i.ordencal)  from cred_tabla_amortiza_variable i
                        where i.numero_credito = TH1.NUMERO_CREDITO)
      and j.numero_credito = TH1.NUMERO_CREDITO) as FECHA_CONCESION,
    /*FECHA_VENCIMIENTO*/
    (select max(j.fecfincal) from cred_tabla_amortiza_variable j
    where j.ordencal = (select max(i.ordencal)  from cred_tabla_amortiza_variable i
                        where i.numero_credito = TH1.NUMERO_CREDITO)
      and j.numero_credito = TH1.NUMERO_CREDITO) as FECHA_VENCIMIENTO,
    (select SUM(ROUND(NVL(CAPITALCAL,0),2) + ROUND(NVL(INTERESCAL,0),2) + ROUND(NVL(MORACAL,0),2) +
              ROUND(CASE WHEN trunc(fecinical)>trunc(sysdate) THEN 0 ELSE NVL(rubroscal,0) END,2)) from CRED_TABLA_AMORTIZA_VARIABLE A
                         where a.numero_credito=TH1.numero_credito
                         and estadocal='P')valor_cancela,
    TH1.DIASMORA_PD,
    TH1.SUCURSAL OFICINA,
    TH1.NOM_OF_CRE CARTERA_HEREDADA,
             (case when th1.oficial_credito in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                   when th1.oficial_credito in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                   when th1.oficial_credito in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                   when th1.oficial_credito in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                   when th1.oficial_credito in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                   when th1.oficial_credito in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                   when th1.oficial_credito in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                   when th1.oficial_credito in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                   when th1.oficial_credito in (85,26,83,48) then ('BALCON')
                   when th1.oficial_credito in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                   when th1.oficial_credito in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                   when th1.oficial_credito in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                   else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=th1.oficial_credito) end
             )ASESOR


    FROM(
      SELECT
          MAX(TH.FECHA_INGRESO)FECHA_INGRESO,
          MAX(TH.COD_SOCIO) SOCIO,
          TH.NUMERO_CREDITO,
          TH.OBSERVACIONES OBSERVA,
          MAX(NOMBRE_SOCIO)NOMBRE,
          MAX(TH.GENERO) GENERO,
          MAX(TH.EDAD) EDAD,
          th.codigo_cicn activ,
          MAX(TH.OBS_ACT)OBS_ACT,
          (CASE WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=1 THEN
                                   CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND   5 THEN 'A1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20 THEN 'A2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  65 THEN 'B1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  95 THEN 'B2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'C1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 126 AND 155 THEN 'C2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 156 AND 185 THEN 'D'
                                   ELSE 'E'
                                   END

                                  --CONSUMO
                                  WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=2 THEN
                                   CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5  THEN 'A1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20  THEN 'A2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  50 THEN 'B1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  51 AND  65 THEN 'B2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  80 THEN 'C1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  81 AND  95 THEN 'C2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'D'
                                   ELSE 'E'
                                   END

                                  --VIVIENDA
                                   WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=3 THEN
                                    CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5 THEN 'A1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  35 THEN 'A2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  65 THEN 'A3'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND 120 THEN 'B1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 121 AND 180 THEN 'B2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 181 AND 210 THEN 'C1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 211 AND 270 THEN 'C2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 271 AND 450 THEN 'D'
                                    ELSE 'E'
                                    END

                                   --MICROEMPRESA
                                   WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=4 THEN
                                    CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5  THEN 'A1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20 THEN 'A2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  50 THEN 'B1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  51 AND  65 THEN 'B2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  80 THEN 'C1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  81 AND  95 THEN 'C2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'D'
                                    ELSE 'E'
                                    END
                            END) CALIFICACION,
          /**/
          MAX(TH.CODIGO_PERIOC) CODIGO_PERIOC,
          MAX(TH.NUM_CUOTAS) NUM_CUOTAS,
          max(th.instruccion)instruc,
          max(th.estado_civil)est_civil,
          MAX(TH.CED) CEDULA,
          MAX(TH.NOMBRE_EMPRESA) EMPRESA,
          max(th.cod_telf) telefono,
          max(th.cod_celular) celular,
          MAX(TH.TIPID) TIP_ID,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I') THEN TH.SCAPITAL ELSE 0 END) AS CAP_ACTIVO,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('D') THEN TH.SCAPITAL ELSE 0 END) AS CAP_NDEVENGA,

           --roger
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('E') THEN TH.SCAPITAL ELSE
                   (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
          END) AS CAP_VENCIDO,
          --select * from cred_tabla_amortiza_variable where numero

         -- SUM(CASE WHEN TH.ESTADO_CARSEG IN('E') THEN TH.SCAPITAL ELSE 0 END) AS CAP_VENCIDO,

           SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE
           (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
            END)CAP_SALDO,
          MAX(TH.MONTO_CREDITO) VAL_CREDITO,
          th.of_cred oficial_credito,
          MAX(FECHAINI) FECHA_CONCESION,
          MAX(FECHAFIN) FECHA_VENCIMIENTO,
          MAX(TH.TASA_TEA)TEA,
          MAX(TH.TASA_TIR)TIR,
          MAX(TH.TASA) TASA,
    --    SELECT *FROM CONF_ACTIV_ECO_SOCIO WHERE CODIGO='G474111'

          SUM(TH.DIASMORAPD) DIASMORA_PD,
          (SELECT NVL(SUM(P.CAPITAL),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE('#{ fechaFin.to_date.strftime('%d-%m-%Y') }','DD/MM/YY'))) AS CAPITAL_CAN,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE 0 END) AS CAPITAL_PEN,
          (
           (SELECT NVL(SUM(P.INTERES),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE('#{ fechaFin.to_date.strftime('%d-%m-%Y') }','DD/MM/YY')))+
           SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SINTERES ELSE 0 END)
          ) AS INTERES_TOTAL,
          (SELECT NVL(SUM(P.INTERES),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE(' #{ fechaFin.to_date.strftime('%d-%m-%Y') }','DD/MM/YY'))) AS INTERES_CAN,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SINTERES ELSE 0 END) AS INTERES_PEN,
          (SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = TH.COD_GRUPO ) AS NOM_GRUPO,
          (SELECT MIN(DESCRIPCION)  FROM CONF_PRODUCTOS P WHERE P.CODIGO_ACT_FINANCIERA = 2 AND P.CODIGO_GRUPO = TH.COD_GRUPO AND P.CODIGO_PRODUCTO = TH.COD_PRODUCTO) AS NOM_PRODUCTO,
          (SELECT MAX(CCD.MCLI_LUGAR_DIR) FROM SOCIOS_DIRECCIONES CCD WHERE CCD.CODIGO_SOCIO = TH.COD_SOCIO) LUGDIR,
          MAX(TH.COD_ORIREC) ORIGENR, MAX(TH.COD_GRUPORG)GRUPORG,
          (SELECT MIN(SS.DESCRIPCION) FROM SIFV_SUCURSALES SS WHERE SS.CODIGO_SUCURSAL = TH.COD_SUCURSAL) AS SUCURSAL,
          (SELECT MIN(USU_APELLIDOS ||' ' || USU_NOMBRES) FROM SIFV_USUARIOS_SISTEMA SU WHERE SU.CODIGO_USUARIO = TH.COD_USUARIO ) AS NOM_USER,
          (SELECT MIN(USU_APELLIDOS ||' ' || USU_NOMBRES) FROM SIFV_USUARIOS_SISTEMA SU WHERE SU.CODIGO_USUARIO = TH.OF_CRED ) AS NOM_OF_CRE,

       MAX(TH.CODIGO_DESTINO)COD_DESTINO
      FROM(
          SELECT
                 MAX(SDG.SING_FECSOLI) FECHA_INGRESO,
                 CC.NUMERO_CREDITO,
                 CH.ESTADO_CARSEG,
                 COUNT(*) AS CONTADOR,
                 SUM(CH.CAPITAL) AS SCAPITAL,/*------------------*/
                 MAX(cc.num_cuotas) NUM_CUOTAS,
                 COUNT(*) AS NUMCUOTAS,
                 MAX(CC.CODIGO_PERIOC) CODIGO_PERIOC, /**/
                 SUM(CH.INTACT) AS SINTERES, /*------------------*/
                 MAX(CC.TASA_INTERES)AS TASA,
                 (select MAX(TEA) from CRED_REGISTRA_TASA_TIR_TEA T WHERE T.NUMERO_CREDITO = CC.NUMERO_CREDITO )AS TASA_TEA,
                 (select MAX(TIR) from CRED_REGISTRA_TASA_TIR_TEA T WHERE T.NUMERO_CREDITO = CC.NUMERO_CREDITO )AS TASA_TIR,
                 MAX(CH.DIAMORACT)AS DIASMORAPD,
                 SUM(CH.DIAMORACT) AS DIASMORAAC,
                 MAX(S.CODIGO_SOCIO)COD_SOCIO,
                 MAX(S.MCLI_NUMERO_ID)CED,
                 MAX(S.CODIGO_IDENTIFICACION) TIPID,
                 (MAX(S.MCLI_APELLIDO_PAT)||' '||MAX(S.MCLI_APELLIDO_MAT)||' '||MAX(S.MCLI_NOMBRES)) AS NOMBRE_SOCIO,
                 MAX(S.MCLI_RAZON_SOCIAL) AS NOMBRE_EMPRESA,
                 MAX(S.MCLI_SEXO) AS GENERO,
                 MAX(S.MCLI_FECNACI) AS EDAD,
                  /*NATTY*/
                 MAX(S.observacion_profesion) AS OBS_ACT,
                 /**/
                 cc.obs_descre OBSERVACIONES,
                 MAX(CC.MONTO_REAL)MONTO_CREDITO,
                 MAX(CC.FECINI) FECHAINI,
                 MAX(CC.FECFIN) FECHAFIN,
                 MAX(CC.CODIGO_GRUPO) COD_GRUPO,
                 MAX(CC.CODIGO_PRODUCTO) COD_PRODUCTO,
                 MAX(CC.CODIGO_ORIREC) COD_ORIREC,
                 MAX(SDG.CODIGO_GRUPORG) COD_GRUPORG,
                 max(sdg.sing_telefonos) cod_telf,
                 max(sdg.sing_telefono_celular) cod_celular,
                 MAX(CC.CODIGO_SUCURSAL) COD_SUCURSAL,
                 MAX(CC.CODIGO_USUARIO) COD_USUARIO,
                 MAX(CC.OFICRE) OF_CRED,
                 MAX(CC.CODIGO_SUBSECTOR)||MAX(cc.codigo_clasificacion_credito) CODIGO_DESTINO,
                 max(s.codigo_instruccion)instruccion,
                 max(s.codigo_estado_civil)estado_civil,
                 MAX(cc.codigo_clasificacion_credito) CODIGO_CICN   --ACTIVIDAD ECONOMICA
            FROM
                CRED_CREDITOS CC,
                CRED_HISTORIAL_REC_CARTERA CH,
                SOCIOS S,
                SOCIOS_SOLISOC_DATOS_GENERALES SDG
           WHERE CC.NUMERO_CREDITO = CH.NUMERO_CREDITO
             AND S.CODIGO_SOCIO = CC.CODIGO_SOCIO
             AND S.CODIGO_SOCIO = SDG.CODIGO_SOCIO
            AND TRUNC(CH.FGENERA) = TO_DATE('#{ fechaFin.to_date.strftime('%d-%m-%Y') }','DD/MM/YY')
            and cc.fecha_credito between TO_DATE('#{ fechaInicio.to_date.strftime('%d-%m-%Y') }','DD/MM/YY') and TO_DATE('#{ fechaFin.to_date.strftime('%d-%m-%Y') }','DD/MM/YY')

            and (case when cc.oficre in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                   when cc.oficre in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                   when cc.oficre in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                   when cc.oficre in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                   when cc.oficre in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                   when cc.oficre in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                   when cc.oficre in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                   when cc.oficre in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                   when cc.oficre in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                   when cc.oficre in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                   when cc.oficre in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                   else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=cc.oficre) end
             ) like upper ('%#{ asesor }%')
                 GROUP BY CC.NUMERO_CREDITO, CH.ESTADO_CARSEG, CC.OBS_DESCRE
      )TH
       GROUP BY TH.NUMERO_CREDITO, TH.COD_GRUPO, TH.COD_PRODUCTO, TH.OF_CRED, TH.COD_USUARIO, TH.COD_SUCURSAL, TH.COD_SOCIO,TH.OBSERVACIONES,th.codigo_cicn

    ) TH1
    where TH1.DIASMORA_PD between #{diaInicio} and #{diaFin}
    ")

    if results.present?
      return results
    else
      return {}
    end
    data = [{
        socio: '43532',
        credito: '645324',
        fecha_ingreso: '12/4/2017',
        codigo_perioc: '234',
        origen_recursos: '123',
        provision_requerida: '412.453',
        cuotas_credito: '4',
        nombre: 'Santy',
        tip_id: '234',
        cedula: '1005048375',
        genero: 'Masculino',
        edad: '23',
        fecha_nacimiento: '10/08/1994',
        calificacion: 'A1',
        cap_activo: '2342.234',
        cap_ndevenga: '64345.324',
        cap_vencido: '6342.734',
        cartera_riesgo: 'No se D:',
        saldo_cartera: 'mucho',
        fecha_concesion: ':D',
        fecha_vencimiento: ':D',
        valor_cancela: '23412.345',
        diasmora_pd: '1',
        oficina: 'Matriz',
        cartera_heredada: 'Pepita',
        asesor: 'Juanito'
    },{
        socio: '43532',
        credito: '645324',
        fecha_ingreso: '12/4/2017',
        codigo_perioc: '234',
        origen_recursos: '123',
        provision_requerida: '412.453',
        cuotas_credito: '4',
        nombre: 'Santy',
        tip_id: '234',
        cedula: '1005048375',
        genero: 'Masculino',
        edad: '23',
        fecha_nacimiento: '10/08/1994',
        calificacion: 'A1',
        cap_activo: '2342.234',
        cap_ndevenga: '64345.324',
        cap_vencido: '6342.734',
        cartera_riesgo: 'No se D:',
        saldo_cartera: 'mucho',
        fecha_concesion: ':D',
        fecha_vencimiento: ':D',
        valor_cancela: '23412.345',
        diasmora_pd: '1',
        oficina: 'Matriz',
        cartera_heredada: 'Pepita',
        asesor: 'Juanito'
    },{
        socio: '43532',
        credito: '645324',
        fecha_ingreso: '12/4/2017',
        codigo_perioc: '234',
        origen_recursos: '123',
        provision_requerida: '412.453',
        cuotas_credito: '4',
        nombre: 'Santy',
        tip_id: '234',
        cedula: '1005048375',
        genero: 'Masculino',
        edad: '23',
        fecha_nacimiento: '10/08/1994',
        calificacion: 'A1',
        cap_activo: '2342.234',
        cap_ndevenga: '64345.324',
        cap_vencido: '6342.734',
        cartera_riesgo: 'No se D:',
        saldo_cartera: 'mucho',
        fecha_concesion: ':D',
        fecha_vencimiento: ':D',
        valor_cancela: '23412.345',
        diasmora_pd: '1',
        oficina: 'Matriz',
        cartera_heredada: 'Pepita',
        asesor: 'Juanito'
    },{
        socio: '43532',
        credito: '645324',
        fecha_ingreso: '12/4/2017',
        codigo_perioc: '234',
        origen_recursos: '123',
        provision_requerida: '412.453',
        cuotas_credito: '4',
        nombre: 'Santy',
        tip_id: '234',
        cedula: '1005048375',
        genero: 'Masculino',
        edad: '23',
        fecha_nacimiento: '10/08/1994',
        calificacion: 'A1',
        cap_activo: '2342.234',
        cap_ndevenga: '64345.324',
        cap_vencido: '6342.734',
        cartera_riesgo: 'No se D:',
        saldo_cartera: 'mucho',
        fecha_concesion: ':D',
        fecha_vencimiento: ':D',
        valor_cancela: '23412.345',
        diasmora_pd: '1',
        oficina: 'Matriz',
        cartera_heredada: 'Pepita',
        asesor: 'Juanito'
    },{
        socio: '43532',
        credito: '645324',
        fecha_ingreso: '12/4/2017',
        codigo_perioc: '234',
        origen_recursos: '123',
        provision_requerida: '412.453',
        cuotas_credito: '4',
        nombre: 'Santy',
        tip_id: '234',
        cedula: '1005048375',
        genero: 'Masculino',
        edad: '23',
        fecha_nacimiento: '10/08/1994',
        calificacion: 'A1',
        cap_activo: '2342.234',
        cap_ndevenga: '64345.324',
        cap_vencido: '6342.734',
        cartera_riesgo: 'No se D:',
        saldo_cartera: 'mucho',
        fecha_concesion: ':D',
        fecha_vencimiento: ':D',
        valor_cancela: '23412.345',
        diasmora_pd: '1',
        oficina: 'Matriz',
        cartera_heredada: 'Pepita',
        asesor: 'Juanito'
    }]
    return data
  end


  def self.obtener_cosechas fecha, agencia, asesor
    if asesor == " "
      asesor = ""
    end
    if agencia == " "
      agencia = ""
    end

    results = connection.exec_query("
    SELECT
    TH1.SOCIO,
    TH1.NUMERO_CREDITO CREDITO,
    (select max(t.tipo_garantia) from seps_historico_c01 t where t.numero_operacion=th1.numero_credito)garantia_vima,

    CASE WHEN TH1.TIP_ID = 'R' THEN TH1.EMPRESA ELSE TH1.NOMBRE END NOMBRE,
    th1.cedula CEDULA,
    round(((sysdate-th1.edad)/360.20),0) EDAD,
    th1.genero GENERO,
    (case th1.est_civil
      when 1 then 'Casado'
      when 2 then 'Soltero'
      when 3 then 'Divorciado'
      when 4 then 'Viudo'
      when 5 then 'Union Libre'
      else 'No Aplica'
      end)
      as ESTADO_CIVIL,
      (select max(inst_descripcion) from socios_instruccion where inst_codigo = th1.instruc) nivel_de_instruccion,
    TH1.CALIFICACION,
    TH1.CAP_SALDO,
    TH1.DIASMORA_PD,
    TH1.NOM_GRUPO,

    (SELECT max(descripcion) FROM CRED_ACT_ECO_DEST_CRE A WHERE A.CODIGO =TH1.activ AND A.NIVEL=5)DESTINO_CREDITO,
    TH1.CODIGO_PERIOC,
    (TH1.NUM_CUOTAS) AS CUOTAS_CREDITO,
    (select count(*) from cred_tabla_amortiza_variable where estadocal='P' and numero_credito=th1.numero_credito) as cuotas_p,
    (case when (select count(*) from cred_tabla_amortiza_variable where estadocal in ('C') and numero_credito=th1.numero_credito)=0 then 1
    else (select max(rownum)+1 from cred_tabla_amortiza_variable ct where estadocal='C' and numero_credito=th1.numero_credito) end
    )cuota_vencida,
    TH1.CAP_SALDO,
    TH1.VAL_CREDITO,
    TH1.CAP_ACTIVO,
    TH1.CAP_NDEVENGA,
    TH1.CAP_VENCIDO,
    (TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)CARTERA_RIESGO,
    (select min(j.fecinical) from cred_tabla_amortiza_variable j
    where j.ordencal = (select min(i.ordencal)  from cred_tabla_amortiza_variable i
                        where i.numero_credito = TH1.NUMERO_CREDITO)
      and j.numero_credito = TH1.NUMERO_CREDITO) as FECHA_CONCESION,
    (select max(j.fecfincal) from cred_tabla_amortiza_variable j
    where j.ordencal = (select max(i.ordencal)  from cred_tabla_amortiza_variable i
                        where i.numero_credito = TH1.NUMERO_CREDITO)
      and j.numero_credito = TH1.NUMERO_CREDITO) as FECHA_VENCIMIENTO,
    (select SUM(ROUND(NVL(CAPITALCAL,0),2) + ROUND(NVL(INTERESCAL,0),2) + ROUND(NVL(MORACAL,0),2) +
              ROUND(CASE WHEN trunc(fecinical)>trunc(sysdate) THEN 0 ELSE NVL(rubroscal,0) END,2)) from CRED_TABLA_AMORTIZA_VARIABLE A
                         where a.numero_credito=TH1.numero_credito
                         and estadocal='P')valor_cancela,
    TH1.TASA,
    TH1.DIASMORA_PD,
    TH1.SUCURSAL OFICINA,
    TH1.NOM_OF_CRE CARTERA_HEREDADA,
             (case when th1.oficial_credito in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                   when th1.oficial_credito in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                   when th1.oficial_credito in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                   when th1.oficial_credito in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                   when th1.oficial_credito in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                   when th1.oficial_credito in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                   when th1.oficial_credito in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                   when th1.oficial_credito in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                   when th1.oficial_credito in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                   when th1.oficial_credito in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                   when th1.oficial_credito in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                   else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=th1.oficial_credito) end
             )ASESOR,
    (SELECT max(DS.TIPO_SECTOR)
        FROM SOCIOS_DIRECCIONES DS WHERE TH1.SOCIO = DS.CODIGO_SOCIO
        AND DS.FECHA_INGRESO = (SELECT MAX(X.FECHA_INGRESO) FROM SOCIOS_DIRECCIONES X WHERE X.CODIGO_SOCIO = TH1.SOCIO)
    )AS SECTOR,
    (
     SELECT MAX(DESCRIPCION) from Sifv_Parroquias d
       WHERE d.codigo_pais = substr(TH1.LUGDIR,1,2)
         and d.codigo_provincia = substr(TH1.LUGDIR,3,2)
         and d.codigo_ciudad = substr(TH1.LUGDIR,5,2)
         and d.codigo_parroquia = substr(TH1.LUGDIR,7,2)
    ) AS PARROQUIA,
    (
     SELECT MAX(DESCRIPCION) from Sifv_Ciudades d
       WHERE d.codigo_pais = substr(TH1.LUGDIR,1,2)
         and d.codigo_provincia = substr(TH1.LUGDIR,3,2)
         and d.codigo_ciudad = substr(TH1.LUGDIR,5,2)
    ) AS CANTON,
    (
     SELECT MAX(DESCRIPCION) FROM SIFV_PROVINCIA D
       WHERE D.CODIGO_PAIS = substr(TH1.LUGDIR,1,2)
         AND D.CODIGO_PROVINCIA = substr(TH1.LUGDIR,3,2)
    )AS PROVINCIA

    FROM(
      SELECT
          MAX(TH.FECHA_INGRESO)FECHA_INGRESO,
          MAX(TH.COD_SOCIO) SOCIO,
          TH.NUMERO_CREDITO,
          TH.OBSERVACIONES OBSERVA,
          MAX(NOMBRE_SOCIO)NOMBRE,
          MAX(TH.GENERO) GENERO,
          MAX(TH.EDAD) EDAD,
          th.codigo_cicn activ,
          MAX(TH.OBS_ACT)OBS_ACT,
          (CASE WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=1 THEN
                                   CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND   5 THEN 'A1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20 THEN 'A2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  65 THEN 'B1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  95 THEN 'B2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'C1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 126 AND 155 THEN 'C2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 156 AND 185 THEN 'D'
                                   ELSE 'E'
                                   END

                                  --CONSUMO
                                  WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=2 THEN
                                   CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5  THEN 'A1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20  THEN 'A2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  50 THEN 'B1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  51 AND  65 THEN 'B2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  80 THEN 'C1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  81 AND  95 THEN 'C2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'D'
                                   ELSE 'E'
                                   END

                                  --VIVIENDA
                                   WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=3 THEN
                                    CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5 THEN 'A1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  35 THEN 'A2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  65 THEN 'A3'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND 120 THEN 'B1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 121 AND 180 THEN 'B2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 181 AND 210 THEN 'C1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 211 AND 270 THEN 'C2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 271 AND 450 THEN 'D'
                                    ELSE 'E'
                                    END

                                   --MICROEMPRESA
                                   WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=4 THEN
                                    CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5  THEN 'A1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20 THEN 'A2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  50 THEN 'B1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  51 AND  65 THEN 'B2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  80 THEN 'C1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  81 AND  95 THEN 'C2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'D'
                                    ELSE 'E'
                                    END
                            END) CALIFICACION,
          /**/
          MAX(TH.CODIGO_PERIOC) CODIGO_PERIOC,
          MAX(TH.NUM_CUOTAS) NUM_CUOTAS,
          max(th.instruccion)instruc,
          max(th.estado_civil)est_civil,
          MAX(TH.CED) CEDULA,
          MAX(TH.NOMBRE_EMPRESA) EMPRESA,
          max(th.cod_telf) telefono,
          max(th.cod_celular) celular,
          MAX(TH.TIPID) TIP_ID,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I') THEN TH.SCAPITAL ELSE 0 END) AS CAP_ACTIVO,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('D') THEN TH.SCAPITAL ELSE 0 END) AS CAP_NDEVENGA,

           --roger
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('E') THEN TH.SCAPITAL ELSE
                   (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
          END) AS CAP_VENCIDO,
          --select * from cred_tabla_amortiza_variable where numero

         -- SUM(CASE WHEN TH.ESTADO_CARSEG IN('E') THEN TH.SCAPITAL ELSE 0 END) AS CAP_VENCIDO,

           SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE
           (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
            END)CAP_SALDO,
          MAX(TH.MONTO_CREDITO) VAL_CREDITO,
          th.of_cred oficial_credito,
          MAX(FECHAINI) FECHA_CONCESION,
          MAX(FECHAFIN) FECHA_VENCIMIENTO,
          MAX(TH.TASA_TEA)TEA,
          MAX(TH.TASA_TIR)TIR,
          MAX(TH.TASA) TASA,
    --    SELECT *FROM CONF_ACTIV_ECO_SOCIO WHERE CODIGO='G474111'

          SUM(TH.DIASMORAPD) DIASMORA_PD,                                       --to_date('05/01/2014','dd/mm/yy')
          (SELECT NVL(SUM(P.CAPITAL),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE('#{fecha.to_date.strftime('%d-%m-%Y')}','DD/MM/YY'))) AS CAPITAL_CAN,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE 0 END) AS CAPITAL_PEN,
          (
           (SELECT NVL(SUM(P.INTERES),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE('#{fecha.to_date.strftime('%d-%m-%Y')}','DD/MM/YY')))+
           SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SINTERES ELSE 0 END)
          ) AS INTERES_TOTAL,
          (SELECT NVL(SUM(P.INTERES),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE('#{fecha.to_date.strftime('%d-%m-%Y')}','DD/MM/YY'))) AS INTERES_CAN,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SINTERES ELSE 0 END) AS INTERES_PEN,
          (SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = TH.COD_GRUPO ) AS NOM_GRUPO,
          (SELECT MIN(DESCRIPCION)  FROM CONF_PRODUCTOS P WHERE P.CODIGO_ACT_FINANCIERA = 2 AND P.CODIGO_GRUPO = TH.COD_GRUPO AND P.CODIGO_PRODUCTO = TH.COD_PRODUCTO) AS NOM_PRODUCTO,
          (SELECT MAX(CCD.MCLI_LUGAR_DIR) FROM SOCIOS_DIRECCIONES CCD WHERE CCD.CODIGO_SOCIO = TH.COD_SOCIO) LUGDIR,
          MAX(TH.COD_ORIREC) ORIGENR, MAX(TH.COD_GRUPORG)GRUPORG,
          (SELECT MIN(SS.DESCRIPCION) FROM SIFV_SUCURSALES SS WHERE SS.CODIGO_SUCURSAL = TH.COD_SUCURSAL) AS SUCURSAL,
          (SELECT MIN(USU_APELLIDOS ||' ' || USU_NOMBRES) FROM SIFV_USUARIOS_SISTEMA SU WHERE SU.CODIGO_USUARIO = TH.COD_USUARIO ) AS NOM_USER,
          (SELECT MIN(USU_APELLIDOS ||' ' || USU_NOMBRES) FROM SIFV_USUARIOS_SISTEMA SU WHERE SU.CODIGO_USUARIO = TH.OF_CRED ) AS NOM_OF_CRE,

       MAX(TH.CODIGO_DESTINO)COD_DESTINO
      FROM(
          SELECT
                 MAX(SDG.SING_FECSOLI) FECHA_INGRESO,
                 CC.NUMERO_CREDITO,
                 CH.ESTADO_CARSEG,
                 COUNT(*) AS CONTADOR,
                 SUM(CH.CAPITAL) AS SCAPITAL,/*------------------*/
                 MAX(cc.num_cuotas) NUM_CUOTAS,
                 COUNT(*) AS NUMCUOTAS,
                 MAX(CC.CODIGO_PERIOC) CODIGO_PERIOC, /**/
                 SUM(CH.INTACT) AS SINTERES, /*------------------*/
                 MAX(CC.TASA_INTERES)AS TASA,
                 (select MAX(TEA) from CRED_REGISTRA_TASA_TIR_TEA T WHERE T.NUMERO_CREDITO = CC.NUMERO_CREDITO )AS TASA_TEA,
                 (select MAX(TIR) from CRED_REGISTRA_TASA_TIR_TEA T WHERE T.NUMERO_CREDITO = CC.NUMERO_CREDITO )AS TASA_TIR,
                 MAX(CH.DIAMORACT)AS DIASMORAPD,
                 SUM(CH.DIAMORACT) AS DIASMORAAC,
                 MAX(S.CODIGO_SOCIO)COD_SOCIO,
                 MAX(S.MCLI_NUMERO_ID)CED,
                 MAX(S.CODIGO_IDENTIFICACION) TIPID,
                 (MAX(S.MCLI_APELLIDO_PAT)||' '||MAX(S.MCLI_APELLIDO_MAT)||' '||MAX(S.MCLI_NOMBRES)) AS NOMBRE_SOCIO,
                 MAX(S.MCLI_RAZON_SOCIAL) AS NOMBRE_EMPRESA,
                 MAX(S.MCLI_SEXO) AS GENERO,
                 MAX(S.MCLI_FECNACI) AS EDAD,
                  /*NATTY*/
                 MAX(S.observacion_profesion) AS OBS_ACT,
                 /**/
                 cc.obs_descre OBSERVACIONES,
                 MAX(CC.MONTO_REAL)MONTO_CREDITO,
                 MAX(CC.FECINI) FECHAINI,
                 MAX(CC.FECFIN) FECHAFIN,
                 MAX(CC.CODIGO_GRUPO) COD_GRUPO,
                 MAX(CC.CODIGO_PRODUCTO) COD_PRODUCTO,
                 MAX(CC.CODIGO_ORIREC) COD_ORIREC,
                 MAX(SDG.CODIGO_GRUPORG) COD_GRUPORG,
                 max(sdg.sing_telefonos) cod_telf,
                 max(sdg.sing_telefono_celular) cod_celular,
                 MAX(CC.CODIGO_SUCURSAL) COD_SUCURSAL,
                 MAX(CC.CODIGO_USUARIO) COD_USUARIO,
                 MAX(CC.OFICRE) OF_CRED,
                 MAX(CC.CODIGO_SUBSECTOR)||MAX(cc.codigo_clasificacion_credito) CODIGO_DESTINO,
                 max(s.codigo_instruccion)instruccion,
                 max(s.codigo_estado_civil)estado_civil,
                 MAX(cc.codigo_clasificacion_credito) CODIGO_CICN   --ACTIVIDAD ECONOMICA
            FROM
                CRED_CREDITOS CC,
                CRED_HISTORIAL_REC_CARTERA CH,
                SOCIOS S,
                SOCIOS_SOLISOC_DATOS_GENERALES SDG
           WHERE CC.NUMERO_CREDITO = CH.NUMERO_CREDITO
             AND S.CODIGO_SOCIO = CC.CODIGO_SOCIO
             AND S.CODIGO_SOCIO = SDG.CODIGO_SOCIO
            AND TRUNC(CH.FGENERA) = TO_DATE('#{fecha.to_date.strftime('%d-%m-%Y')}','DD/MM/YY')
            and  (SELECT MIN(SS.DESCRIPCION) FROM SIFV_SUCURSALES SS WHERE SS.CODIGO_SUCURSAL = cc.codigo_sucursal) like ('%#{agencia}%')

            and (case when cc.oficre in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                   when cc.oficre in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                   when cc.oficre in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                   when cc.oficre in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                   when cc.oficre in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                   when cc.oficre in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                   when cc.oficre in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                   when cc.oficre in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                   when cc.oficre in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                   when cc.oficre in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                   when cc.oficre in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                   else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=cc.oficre) end
             ) like ('%#{asesor}%')
                 GROUP BY CC.NUMERO_CREDITO, CH.ESTADO_CARSEG, CC.OBS_DESCRE
      )TH
       GROUP BY TH.NUMERO_CREDITO, TH.COD_GRUPO, TH.COD_PRODUCTO, TH.OF_CRED, TH.COD_USUARIO, TH.COD_SUCURSAL, TH.COD_SOCIO,TH.OBSERVACIONES,th.codigo_cicn

    ) TH1
    where (TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)>0
    ")




    if results.present?
      return results
    else
      return {}
    end


    data = [{
      socio: '5343',
      credito: '3452',
      cap_activo: '6456.345',
      cap_ndevenga: '456.345',
      cap_vencido: '45623.324',
      calificacion: 'A',
      cartera_riesgo: '1000',
      nombre: 'Santy',
      cedula: '1005738574',
      tip_id: 'C',
      fecha_concesion: '12-10-2009'
    },{
        socio: '5343',
        credito: '3452',
        cap_activo: '6456.345',
        cap_ndevenga: '456.345',
        cap_vencido: '45623.324',
        calificacion: 'A',
        cartera_riesgo: '1000',
        nombre: 'Santy',
        cedula: '1005738574',
        tip_id: 'C',
        fecha_concesion: '12-01-2010'
    },{
        socio: '5343',
        credito: '3452',
        cap_activo: '6456.345',
        cap_ndevenga: '456.345',
        cap_vencido: '45623.324',
        calificacion: 'A',
        cartera_riesgo: '1000',
        nombre: 'Santy',
        cedula: '1005738574',
        tip_id: 'C',
        fecha_concesion: '12-4-2011'
    },{
        socio: '5343',
        credito: '3452',
        cap_activo: '6456.345',
        cap_ndevenga: '456.345',
        cap_vencido: '45623.324',
        calificacion: 'A',
        cartera_riesgo: '1000',
        nombre: 'Santy',
        cedula: '1005738574',
        tip_id: 'C',
        fecha_concesion: '12-9-2011'
    },{
        socio: '5343',
        credito: '3452',
        cap_activo: '6456.345',
        cap_ndevenga: '456.345',
        cap_vencido: '45623.324',
        calificacion: 'A',
        cartera_riesgo: '1000',
        nombre: 'Santy',
        cedula: '1005738574',
        tip_id: 'C',
        fecha_concesion: '12-10-2012'
    },{
        socio: '5343',
        credito: '3452',
        cap_activo: '6456.345',
        cap_ndevenga: '456.345',
        cap_vencido: '45623.324',
        calificacion: 'A',
        cartera_riesgo: '1000',
        nombre: 'Santy',
        cedula: '1005738574',
        tip_id: 'C',
        fecha_concesion: '12-10-2012'
    }]
    return data;
  end


  def self.indicadores_creditos_vigentes fecha, dia_inicio, dia_fin, agencia, asesor
    if asesor == " "
      asesor = ""
    end
    if agencia == " "
      agencia = ""
    end
    results = connection.exec_query("
    SELECT
    TH1.FECHA_INGRESO FECHA_INGRESO,
    (select MAX(descripcion) from cred_tipos_recursos_economicos where codigo = TH1.ORIGENR) as ORIGEN_RECURSOS,
    TH1.SOCIO,
    TH1.NUMERO_CREDITO CREDITO,

    CASE WHEN TH1.TIP_ID = 'R' THEN TH1.EMPRESA ELSE TH1.NOMBRE END NOMBRE,

    TH1.GENERO GENERO,

    TH1.CALIFICACION,
    TH1.CAP_ACTIVO,
    TH1.CAP_NDEVENGA,
    TH1.CAP_VENCIDO,
    (TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)CARTERA_RIESGO,
    (TH1.CAP_ACTIVO+
    TH1.CAP_NDEVENGA+
    TH1.CAP_VENCIDO)saldo_cartera,
    /*FECHA CONCESION
    (select min(j.fecinical) from cred_tabla_amortiza_variable j
    where j.ordencal = (select min(i.ordencal)  from cred_tabla_amortiza_variable i
                        where i.numero_credito = TH1.NUMERO_CREDITO)
      and j.numero_credito = TH1.NUMERO_CREDITO) as FECHA_CONCESION,
    /*FECHA_VENCIMIENTO
    (select max(j.fecfincal) from cred_tabla_amortiza_variable j
    where j.ordencal = (select max(i.ordencal)  from cred_tabla_amortiza_variable i
                        where i.numero_credito = TH1.NUMERO_CREDITO)
      and j.numero_credito = TH1.NUMERO_CREDITO) as FECHA_VENCIMIENTO,
    (select SUM(ROUND(NVL(CAPITALCAL,0),2) + ROUND(NVL(INTERESCAL,0),2) + ROUND(NVL(MORACAL,0),2) +
              ROUND(CASE WHEN trunc(fecinical)>trunc(sysdate) THEN 0 ELSE NVL(rubroscal,0) END,2)) from CRED_TABLA_AMORTIZA_VARIABLE A
                         where a.numero_credito=TH1.numero_credito
                         and estadocal='P')valor_cancela,
    TH1.DIASMORA_PD,
    */
    TH1.SUCURSAL OFICINA,
    TH1.NOM_OF_CRE CARTERA_HEREDADA,
             (case when th1.oficial_credito in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                   when th1.oficial_credito in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                   when th1.oficial_credito in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                   when th1.oficial_credito in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                   when th1.oficial_credito in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                   when th1.oficial_credito in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                   when th1.oficial_credito in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                   when th1.oficial_credito in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                   when th1.oficial_credito in (85,26,83,48) then ('BALCON')
                   when th1.oficial_credito in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                   when th1.oficial_credito in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                   when th1.oficial_credito in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                   else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=th1.oficial_credito) end
             )ASESOR,
             (SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = th1.grupo_credito) AS tipo_credito,
             (SELECT max(DS.TIPO_SECTOR)
                  FROM SOCIOS_DIRECCIONES DS WHERE TH1.SOCIO = DS.CODIGO_SOCIO
                  AND DS.FECHA_INGRESO = (SELECT MAX(X.FECHA_INGRESO) FROM SOCIOS_DIRECCIONES X WHERE X.CODIGO_SOCIO = TH1.SOCIO)
                  )AS SECTOR,
             (select metodologia from cred_creditos where numero_credito=TH1.NUMERO_CREDITO)metodologia
    FROM(
      SELECT
          MAX(TH.FECHA_INGRESO)FECHA_INGRESO,
          MAX(TH.COD_SOCIO) SOCIO,
          TH.NUMERO_CREDITO,
          TH.OBSERVACIONES OBSERVA,
          MAX(NOMBRE_SOCIO)NOMBRE,
          MAX(TH.GENERO) GENERO,
          MAX(TH.EDAD) EDAD,
          th.codigo_cicn activ,
          MAX(TH.OBS_ACT)OBS_ACT,
          th.cod_grupo grupo_credito,
          (CASE WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=1 THEN
                                   CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND   5 THEN 'A1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20 THEN 'A2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  65 THEN 'B1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  95 THEN 'B2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'C1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 126 AND 155 THEN 'C2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 156 AND 185 THEN 'D'
                                   ELSE 'E'
                                   END
                                  --CONSUMO
                                  WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=2 THEN
                                   CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5  THEN 'A1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20  THEN 'A2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  50 THEN 'B1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  51 AND  65 THEN 'B2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  80 THEN 'C1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  81 AND  95 THEN 'C2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'D'
                                   ELSE 'E'
                                   END
                                  --VIVIENDA
                                   WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=3 THEN
                                    CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5 THEN 'A1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  35 THEN 'A2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  65 THEN 'A3'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND 120 THEN 'B1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 121 AND 180 THEN 'B2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 181 AND 210 THEN 'C1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 211 AND 270 THEN 'C2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 271 AND 450 THEN 'D'
                                    ELSE 'E'
                                    END
                                   --MICROEMPRESA
                                   WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=4 THEN
                                    CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5  THEN 'A1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20 THEN 'A2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  50 THEN 'B1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  51 AND  65 THEN 'B2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  80 THEN 'C1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  81 AND  95 THEN 'C2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'D'
                                    ELSE 'E'
                                    END
                            END) CALIFICACION,
          MAX(TH.CODIGO_PERIOC) CODIGO_PERIOC,
          MAX(TH.NUM_CUOTAS) NUM_CUOTAS,
          max(th.instruccion)instruc,
          max(th.estado_civil)est_civil,
          MAX(TH.CED) CEDULA,
          MAX(TH.NOMBRE_EMPRESA) EMPRESA,
          max(th.cod_telf) telefono,
          max(th.cod_celular) celular,
          MAX(TH.TIPID) TIP_ID,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I') THEN TH.SCAPITAL ELSE 0 END) AS CAP_ACTIVO,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('D') THEN TH.SCAPITAL ELSE 0 END) AS CAP_NDEVENGA,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('E') THEN TH.SCAPITAL ELSE
                   (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
          END) AS CAP_VENCIDO,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE
           (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
            END)CAP_SALDO,
          MAX(TH.MONTO_CREDITO) VAL_CREDITO,
          th.of_cred oficial_credito,
          MAX(FECHAINI) FECHA_CONCESION,
          MAX(FECHAFIN) FECHA_VENCIMIENTO,
          MAX(TH.TASA_TEA)TEA,
          MAX(TH.TASA_TIR)TIR,
          MAX(TH.TASA) TASA,
          SUM(TH.DIASMORAPD) DIASMORA_PD,
          (SELECT NVL(SUM(P.CAPITAL),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE('#{fecha.to_date.strftime('%d-%m-%Y')}','DD/MM/YY'))) AS CAPITAL_CAN,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE 0 END) AS CAPITAL_PEN,
          (
           (SELECT NVL(SUM(P.INTERES),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE('#{fecha.to_date.strftime('%d-%m-%Y')}','DD/MM/YY')))+
           SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SINTERES ELSE 0 END)
          ) AS INTERES_TOTAL,
          (SELECT NVL(SUM(P.INTERES),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE('#{fecha.to_date.strftime('%d-%m-%Y')}','DD/MM/YY'))) AS INTERES_CAN,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SINTERES ELSE 0 END) AS INTERES_PEN,
          (SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = TH.COD_GRUPO ) AS NOM_GRUPO,
          (SELECT MIN(DESCRIPCION)  FROM CONF_PRODUCTOS P WHERE P.CODIGO_ACT_FINANCIERA = 2 AND P.CODIGO_GRUPO = TH.COD_GRUPO AND P.CODIGO_PRODUCTO = TH.COD_PRODUCTO) AS NOM_PRODUCTO,
          (SELECT MAX(CCD.MCLI_LUGAR_DIR) FROM SOCIOS_DIRECCIONES CCD WHERE CCD.CODIGO_SOCIO = TH.COD_SOCIO) LUGDIR,
          MAX(TH.COD_ORIREC) ORIGENR, MAX(TH.COD_GRUPORG)GRUPORG,
          (SELECT MIN(SS.DESCRIPCION) FROM SIFV_SUCURSALES SS WHERE SS.CODIGO_SUCURSAL = TH.COD_SUCURSAL) AS SUCURSAL,
          (SELECT MIN(USU_APELLIDOS ||' ' || USU_NOMBRES) FROM SIFV_USUARIOS_SISTEMA SU WHERE SU.CODIGO_USUARIO = TH.COD_USUARIO ) AS NOM_USER,
          (SELECT MIN(USU_APELLIDOS ||' ' || USU_NOMBRES) FROM SIFV_USUARIOS_SISTEMA SU WHERE SU.CODIGO_USUARIO = TH.OF_CRED ) AS NOM_OF_CRE,
       MAX(TH.CODIGO_DESTINO)COD_DESTINO
      FROM(
          SELECT
                 MAX(SDG.SING_FECSOLI) FECHA_INGRESO,
                 CC.NUMERO_CREDITO,
                 CH.ESTADO_CARSEG,
                 COUNT(*) AS CONTADOR,
                 SUM(CH.CAPITAL) AS SCAPITAL,/*------------------*/
                 MAX(cc.num_cuotas) NUM_CUOTAS,
                 COUNT(*) AS NUMCUOTAS,
                 MAX(CC.CODIGO_PERIOC) CODIGO_PERIOC, /**/
                 SUM(CH.INTACT) AS SINTERES, /*------------------*/
                 MAX(CC.TASA_INTERES)AS TASA,
                 (select MAX(TEA) from CRED_REGISTRA_TASA_TIR_TEA T WHERE T.NUMERO_CREDITO = CC.NUMERO_CREDITO )AS TASA_TEA,
                 (select MAX(TIR) from CRED_REGISTRA_TASA_TIR_TEA T WHERE T.NUMERO_CREDITO = CC.NUMERO_CREDITO )AS TASA_TIR,
                 MAX(CH.DIAMORACT)AS DIASMORAPD,
                 SUM(CH.DIAMORACT) AS DIASMORAAC,
                 MAX(S.CODIGO_SOCIO)COD_SOCIO,
                 MAX(S.MCLI_NUMERO_ID)CED,
                 MAX(S.CODIGO_IDENTIFICACION) TIPID,
                 (MAX(S.MCLI_APELLIDO_PAT)||' '||MAX(S.MCLI_APELLIDO_MAT)||' '||MAX(S.MCLI_NOMBRES)) AS NOMBRE_SOCIO,
                 MAX(S.MCLI_RAZON_SOCIAL) AS NOMBRE_EMPRESA,
                 MAX(S.MCLI_SEXO) AS GENERO,
                 MAX(S.MCLI_FECNACI) AS EDAD,
                  /*NATTY*/
                 MAX(S.observacion_profesion) AS OBS_ACT,
                 /**/
                 cc.obs_descre OBSERVACIONES,
                 MAX(CC.MONTO_REAL)MONTO_CREDITO,
                 MAX(CC.FECINI) FECHAINI,
                 MAX(CC.FECFIN) FECHAFIN,
                 MAX(CC.CODIGO_GRUPO) COD_GRUPO,
                 MAX(CC.CODIGO_PRODUCTO) COD_PRODUCTO,
                 MAX(CC.CODIGO_ORIREC) COD_ORIREC,
                 MAX(SDG.CODIGO_GRUPORG) COD_GRUPORG,
                 max(sdg.sing_telefonos) cod_telf,
                 max(sdg.sing_telefono_celular) cod_celular,
                 MAX(CC.CODIGO_SUCURSAL) COD_SUCURSAL,
                 MAX(CC.CODIGO_USUARIO) COD_USUARIO,
                 MAX(CC.OFICRE) OF_CRED,
                 MAX(CC.CODIGO_SUBSECTOR)||MAX(cc.codigo_clasificacion_credito) CODIGO_DESTINO,
                 max(s.codigo_instruccion)instruccion,
                 max(s.codigo_estado_civil)estado_civil,
                 MAX(cc.codigo_clasificacion_credito) CODIGO_CICN   --ACTIVIDAD ECONOMICA
            FROM
                CRED_CREDITOS CC,
                CRED_HISTORIAL_REC_CARTERA CH,
                SOCIOS S,
                SOCIOS_SOLISOC_DATOS_GENERALES SDG
           WHERE CC.NUMERO_CREDITO = CH.NUMERO_CREDITO
             AND S.CODIGO_SOCIO = CC.CODIGO_SOCIO
             AND S.CODIGO_SOCIO = SDG.CODIGO_SOCIO
            AND TRUNC(CH.FGENERA) = TO_DATE('#{ fecha.to_date.strftime('%d-%m-%Y') }','DD/MM/YYyy')
            and (case when cc.oficre in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                   when cc.oficre in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                   when cc.oficre in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                   when cc.oficre in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                   when cc.oficre in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                   when cc.oficre in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                   when cc.oficre in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                   when cc.oficre in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                   when cc.oficre in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                   when cc.oficre in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                   when cc.oficre in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                   else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=cc.oficre) end
             ) like upper ('%#{asesor}%')
                 GROUP BY CC.NUMERO_CREDITO, CH.ESTADO_CARSEG, CC.OBS_DESCRE
      )TH
       GROUP BY TH.NUMERO_CREDITO, TH.COD_GRUPO, TH.COD_PRODUCTO, TH.OF_CRED, TH.COD_USUARIO, TH.COD_SUCURSAL, TH.COD_SOCIO,TH.OBSERVACIONES,th.codigo_cicn

    ) TH1
    where TH1.DIASMORA_PD between #{dia_inicio.to_i} and #{dia_fin.to_i}
    and   TH1.SUCURSAL like ('%#{agencia}%')
    ")
    
    if results.present?
      return results
    else
      return {}
    end
    data =[
      {
        genero: 'masculino',
        origen_recursos: 'kiva',
        sector: 'Rural',
        tipo_credito: 'Microcredito',
        saldo: '2000',
        cap_activo: '23452.234',
        cap_ndevenga: '6323.542',
        cartera_riesgo: '92823',
        cap_vencido: '98243.928'
      },
      {
        genero: 'femenino',
        origen_recursos: 'triods',
        sector: 'Urbano',
        tipo_credito: 'Consumo',
        saldo: '1000',
        cap_activo: '23452.234',
        cap_ndevenga: '6323.542',
        cartera_riesgo: '92823',
        cap_vencido: '98243.928'
      },
      {
        genero: 'juridico',
        origen_recursos: 'kiva',
        sector: 'Rural',
        tipo_credito: 'Comercial',
        saldo: '3000',
        cap_activo: '543.234',
        cap_ndevenga: '7524.542',
        cartera_riesgo: '7546.75',
        cap_vencido: '56464.56'
      },
      {
        genero: 'masculino',
        origen_recursos: 'kiva',
        sector: 'Urbano',
        tipo_credito: 'Comercial',
        saldo: '4000',
        cap_activo: '653.234',
        cap_ndevenga: '856.542',
        cartera_riesgo: '124748',
        cap_vencido: '674687.928'
      },
      {
          genero: 'juridico',
          origen_recursos: 'extra',
          sector: 'Urbano',
          tipo_credito: 'Comercial',
          saldo: '100',
          cap_activo: '100',
          cap_ndevenga: '100',
          cartera_riesgo: '100',
          cap_vencido: '100'
      },{
          genero: 'xxxxx',
          origen_recursos: 'extra',
          sector: 'Urbano',
          tipo_credito: 'Comercial',
          saldo: '100',
          cap_activo: '100',
          cap_ndevenga: '100',
          cartera_riesgo: '100',
          cap_vencido: '100'
      }
    ]

  end

  def self.indicadores_creditos_colocados fecha_inicio, fecha_fin, dia_inicio, dia_fin, agencia, asesor
    if asesor == " "
      asesor = ""
    end
    if agencia == " "
      agencia = ""
    end

    results = connection.exec_query("
    SELECT
    TH1.FECHA_INGRESO FECHA_INGRESO,
    (select MAX(descripcion) from cred_tipos_recursos_economicos where codigo = TH1.ORIGENR) as ORIGEN_RECURSOS,
    TH1.SOCIO,
    TH1.NUMERO_CREDITO CREDITO,

    CASE WHEN TH1.TIP_ID = 'R' THEN TH1.EMPRESA ELSE TH1.NOMBRE END NOMBRE,

    TH1.GENERO GENERO,

    TH1.CALIFICACION,
    TH1.CAP_ACTIVO,
    TH1.CAP_NDEVENGA,
    TH1.CAP_VENCIDO,
    (TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)CARTERA_RIESGO,
    (TH1.CAP_ACTIVO+
    TH1.CAP_NDEVENGA+
    TH1.CAP_VENCIDO)saldo_cartera,
    /*FECHA CONCESION
    (select min(j.fecinical) from cred_tabla_amortiza_variable j
    where j.ordencal = (select min(i.ordencal)  from cred_tabla_amortiza_variable i
                        where i.numero_credito = TH1.NUMERO_CREDITO)
      and j.numero_credito = TH1.NUMERO_CREDITO) as FECHA_CONCESION,
    /*FECHA_VENCIMIENTO
    (select max(j.fecfincal) from cred_tabla_amortiza_variable j
    where j.ordencal = (select max(i.ordencal)  from cred_tabla_amortiza_variable i
                        where i.numero_credito = TH1.NUMERO_CREDITO)
      and j.numero_credito = TH1.NUMERO_CREDITO) as FECHA_VENCIMIENTO,
    (select SUM(ROUND(NVL(CAPITALCAL,0),2) + ROUND(NVL(INTERESCAL,0),2) + ROUND(NVL(MORACAL,0),2) +
              ROUND(CASE WHEN trunc(fecinical)>trunc(sysdate) THEN 0 ELSE NVL(rubroscal,0) END,2)) from CRED_TABLA_AMORTIZA_VARIABLE A
                         where a.numero_credito=TH1.numero_credito
                         and estadocal='P')valor_cancela,
    TH1.DIASMORA_PD,
    */
    TH1.SUCURSAL OFICINA,
    TH1.NOM_OF_CRE CARTERA_HEREDADA,
             (case when th1.oficial_credito in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                   when th1.oficial_credito in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                   when th1.oficial_credito in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                   when th1.oficial_credito in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                   when th1.oficial_credito in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                   when th1.oficial_credito in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                   when th1.oficial_credito in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                   when th1.oficial_credito in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                   when th1.oficial_credito in (85,26,83,48) then ('BALCON')
                   when th1.oficial_credito in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                   when th1.oficial_credito in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                   when th1.oficial_credito in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                   else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=th1.oficial_credito) end
             )ASESOR,
             (SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = th1.grupo_credito) AS tipo_credito,
             (SELECT max(DS.TIPO_SECTOR)
                  FROM SOCIOS_DIRECCIONES DS WHERE TH1.SOCIO = DS.CODIGO_SOCIO
                  AND DS.FECHA_INGRESO = (SELECT MAX(X.FECHA_INGRESO) FROM SOCIOS_DIRECCIONES X WHERE X.CODIGO_SOCIO = TH1.SOCIO)
                  )AS SECTOR,
             (select metodologia from cred_creditos where numero_credito=TH1.NUMERO_CREDITO)metodologia
    FROM(
      SELECT
          MAX(TH.FECHA_INGRESO)FECHA_INGRESO,
          MAX(TH.COD_SOCIO) SOCIO,
          TH.NUMERO_CREDITO,
          TH.OBSERVACIONES OBSERVA,
          MAX(NOMBRE_SOCIO)NOMBRE,
          MAX(TH.GENERO) GENERO,
          MAX(TH.EDAD) EDAD,
          th.codigo_cicn activ,
          MAX(TH.OBS_ACT)OBS_ACT,
          th.cod_grupo grupo_credito,
          (CASE WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=1 THEN
                                   CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND   5 THEN 'A1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20 THEN 'A2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  65 THEN 'B1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  95 THEN 'B2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'C1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 126 AND 155 THEN 'C2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 156 AND 185 THEN 'D'
                                   ELSE 'E'
                                   END
                                  --CONSUMO
                                  WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=2 THEN
                                   CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5  THEN 'A1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20  THEN 'A2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  50 THEN 'B1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  51 AND  65 THEN 'B2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  80 THEN 'C1'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  81 AND  95 THEN 'C2'
                                        WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'D'
                                   ELSE 'E'
                                   END
                                  --VIVIENDA
                                   WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=3 THEN
                                    CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5 THEN 'A1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  35 THEN 'A2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  65 THEN 'A3'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND 120 THEN 'B1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 121 AND 180 THEN 'B2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 181 AND 210 THEN 'C1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 211 AND 270 THEN 'C2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN 271 AND 450 THEN 'D'
                                    ELSE 'E'
                                    END
                                   --MICROEMPRESA
                                   WHEN MAX((SELECT CODIGO_GRUPO FROM CRED_GRUPO_SEGMENTOS_CREDITO WHERE CODIGO_GRUPO=TH.COD_GRUPO))=4 THEN
                                    CASE WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   0 AND  5  THEN 'A1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN   6 AND  20 THEN 'A2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  21 AND  35 THEN 'A3'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  36 AND  50 THEN 'B1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  51 AND  65 THEN 'B2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  66 AND  80 THEN 'C1'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  81 AND  95 THEN 'C2'
                                         WHEN nvl(MAX(TH.DIASMORAPD),0) BETWEEN  96 AND 125 THEN 'D'
                                    ELSE 'E'
                                    END
                            END) CALIFICACION,
          MAX(TH.CODIGO_PERIOC) CODIGO_PERIOC,
          MAX(TH.NUM_CUOTAS) NUM_CUOTAS,
          max(th.instruccion)instruc,
          max(th.estado_civil)est_civil,
          MAX(TH.CED) CEDULA,
          MAX(TH.NOMBRE_EMPRESA) EMPRESA,
          max(th.cod_telf) telefono,
          max(th.cod_celular) celular,
          MAX(TH.TIPID) TIP_ID,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I') THEN TH.SCAPITAL ELSE 0 END) AS CAP_ACTIVO,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('D') THEN TH.SCAPITAL ELSE 0 END) AS CAP_NDEVENGA,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('E') THEN TH.SCAPITAL ELSE
                   (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
          END) AS CAP_VENCIDO,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE
           (case when (select distinct(numero_credito) from cred_tabla_amortiza_variable where estado='S' and numero_credito=th.numero_credito)=th.numero_credito then 1 else 0 end)
            END)CAP_SALDO,
          MAX(TH.MONTO_CREDITO) VAL_CREDITO,
          th.of_cred oficial_credito,
          MAX(FECHAINI) FECHA_CONCESION,
          MAX(FECHAFIN) FECHA_VENCIMIENTO,
          MAX(TH.TASA_TEA)TEA,
          MAX(TH.TASA_TIR)TIR,
          MAX(TH.TASA) TASA,
          SUM(TH.DIASMORAPD) DIASMORA_PD,
          (SELECT NVL(SUM(P.CAPITAL),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','DD/MM/YY'))) AS CAPITAL_CAN,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SCAPITAL ELSE 0 END) AS CAPITAL_PEN,
          (
           (SELECT NVL(SUM(P.INTERES),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','DD/MM/YY')))+
           SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SINTERES ELSE 0 END)
          ) AS INTERES_TOTAL,
          (SELECT NVL(SUM(P.INTERES),0) FROM CRED_CABECERA_PAGOS_CREDITO P WHERE P.NUMERO_CREDITO = TH.NUMERO_CREDITO AND TRUNC(P.FECHA) <= TRUNC(TO_DATE('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','DD/MM/YY'))) AS INTERES_CAN,
          SUM(CASE WHEN TH.ESTADO_CARSEG IN('I','D','E') THEN TH.SINTERES ELSE 0 END) AS INTERES_PEN,
          (SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = TH.COD_GRUPO ) AS NOM_GRUPO,
          (SELECT MIN(DESCRIPCION)  FROM CONF_PRODUCTOS P WHERE P.CODIGO_ACT_FINANCIERA = 2 AND P.CODIGO_GRUPO = TH.COD_GRUPO AND P.CODIGO_PRODUCTO = TH.COD_PRODUCTO) AS NOM_PRODUCTO,
          (SELECT MAX(CCD.MCLI_LUGAR_DIR) FROM SOCIOS_DIRECCIONES CCD WHERE CCD.CODIGO_SOCIO = TH.COD_SOCIO) LUGDIR,
          MAX(TH.COD_ORIREC) ORIGENR, MAX(TH.COD_GRUPORG)GRUPORG,
          (SELECT MIN(SS.DESCRIPCION) FROM SIFV_SUCURSALES SS WHERE SS.CODIGO_SUCURSAL = TH.COD_SUCURSAL) AS SUCURSAL,
          (SELECT MIN(USU_APELLIDOS ||' ' || USU_NOMBRES) FROM SIFV_USUARIOS_SISTEMA SU WHERE SU.CODIGO_USUARIO = TH.COD_USUARIO ) AS NOM_USER,
          (SELECT MIN(USU_APELLIDOS ||' ' || USU_NOMBRES) FROM SIFV_USUARIOS_SISTEMA SU WHERE SU.CODIGO_USUARIO = TH.OF_CRED ) AS NOM_OF_CRE,
       MAX(TH.CODIGO_DESTINO)COD_DESTINO
      FROM(
          SELECT
                 MAX(SDG.SING_FECSOLI) FECHA_INGRESO,
                 CC.NUMERO_CREDITO,
                 CH.ESTADO_CARSEG,
                 COUNT(*) AS CONTADOR,
                 SUM(CH.CAPITAL) AS SCAPITAL,/*------------------*/
                 MAX(cc.num_cuotas) NUM_CUOTAS,
                 COUNT(*) AS NUMCUOTAS,
                 MAX(CC.CODIGO_PERIOC) CODIGO_PERIOC, /**/
                 SUM(CH.INTACT) AS SINTERES, /*------------------*/
                 MAX(CC.TASA_INTERES)AS TASA,
                 (select MAX(TEA) from CRED_REGISTRA_TASA_TIR_TEA T WHERE T.NUMERO_CREDITO = CC.NUMERO_CREDITO )AS TASA_TEA,
                 (select MAX(TIR) from CRED_REGISTRA_TASA_TIR_TEA T WHERE T.NUMERO_CREDITO = CC.NUMERO_CREDITO )AS TASA_TIR,
                 MAX(CH.DIAMORACT)AS DIASMORAPD,
                 SUM(CH.DIAMORACT) AS DIASMORAAC,
                 MAX(S.CODIGO_SOCIO)COD_SOCIO,
                 MAX(S.MCLI_NUMERO_ID)CED,
                 MAX(S.CODIGO_IDENTIFICACION) TIPID,
                 (MAX(S.MCLI_APELLIDO_PAT)||' '||MAX(S.MCLI_APELLIDO_MAT)||' '||MAX(S.MCLI_NOMBRES)) AS NOMBRE_SOCIO,
                 MAX(S.MCLI_RAZON_SOCIAL) AS NOMBRE_EMPRESA,
                 MAX(S.MCLI_SEXO) AS GENERO,
                 MAX(S.MCLI_FECNACI) AS EDAD,
                  /*NATTY*/
                 MAX(S.observacion_profesion) AS OBS_ACT,
                 /**/
                 cc.obs_descre OBSERVACIONES,
                 MAX(CC.MONTO_REAL)MONTO_CREDITO,
                 MAX(CC.FECINI) FECHAINI,
                 MAX(CC.FECFIN) FECHAFIN,
                 MAX(CC.CODIGO_GRUPO) COD_GRUPO,
                 MAX(CC.CODIGO_PRODUCTO) COD_PRODUCTO,
                 MAX(CC.CODIGO_ORIREC) COD_ORIREC,
                 MAX(SDG.CODIGO_GRUPORG) COD_GRUPORG,
                 max(sdg.sing_telefonos) cod_telf,
                 max(sdg.sing_telefono_celular) cod_celular,
                 MAX(CC.CODIGO_SUCURSAL) COD_SUCURSAL,
                 MAX(CC.CODIGO_USUARIO) COD_USUARIO,
                 MAX(CC.OFICRE) OF_CRED,
                 MAX(CC.CODIGO_SUBSECTOR)||MAX(cc.codigo_clasificacion_credito) CODIGO_DESTINO,
                 max(s.codigo_instruccion)instruccion,
                 max(s.codigo_estado_civil)estado_civil,
                 MAX(cc.codigo_clasificacion_credito) CODIGO_CICN   --ACTIVIDAD ECONOMICA
            FROM
                CRED_CREDITOS CC,
                CRED_HISTORIAL_REC_CARTERA CH,
                SOCIOS S,
                SOCIOS_SOLISOC_DATOS_GENERALES SDG
           WHERE CC.NUMERO_CREDITO = CH.NUMERO_CREDITO
             AND S.CODIGO_SOCIO = CC.CODIGO_SOCIO
             AND S.CODIGO_SOCIO = SDG.CODIGO_SOCIO
            AND TRUNC(CH.FGENERA) = TO_DATE('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','DD/MM/YYyy')
            and cc.fecha_credito between TO_DATE('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','DD/MM/YYyy') and TO_DATE('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','DD/MM/YYyy')
            and (case when cc.oficre in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                   when cc.oficre in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                   when cc.oficre in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                   when cc.oficre in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                   when cc.oficre in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                   when cc.oficre in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                   when cc.oficre in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                   when cc.oficre in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                   when cc.oficre in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                   when cc.oficre in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                   when cc.oficre in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                   else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=cc.oficre) end
             ) like upper ('%#{asesor}%')
                 GROUP BY CC.NUMERO_CREDITO, CH.ESTADO_CARSEG, CC.OBS_DESCRE
      )TH
       GROUP BY TH.NUMERO_CREDITO, TH.COD_GRUPO, TH.COD_PRODUCTO, TH.OF_CRED, TH.COD_USUARIO, TH.COD_SUCURSAL, TH.COD_SOCIO,TH.OBSERVACIONES,th.codigo_cicn

    ) TH1
    where TH1.DIASMORA_PD between #{dia_inicio.to_i} and #{dia_fin.to_i}
    and   TH1.SUCURSAL like ('%#{agencia}%')
    ")
    if results.present?
      return results
    else
      return {}
    end


    data =[
      {
        genero: 'masculino',
        origen_recursos: 'kiva',
        sector: 'Rural',
        tipo_credito: 'Microcredito',
        saldo: '2000',
        cap_activo: '23452.234',
        cap_ndevenga: '6323.542',
        cartera_riesgo: '92823',
        cap_vencido: '98243.928'
      },
      {
        genero: 'femenino',
        origen_recursos: 'triods',
        sector: 'Urbano',
        tipo_credito: 'Consumo',
        saldo: '1000',
        cap_activo: '23452.234',
        cap_ndevenga: '6323.542',
        cartera_riesgo: '92823',
        cap_vencido: '98243.928'
      },
      {
        genero: 'juridico',
        origen_recursos: 'kiva',
        sector: 'Rural',
        tipo_credito: 'Comercial',
        saldo: '3000',
        cap_activo: '543.234',
        cap_ndevenga: '7524.542',
        cartera_riesgo: '7546.75',
        cap_vencido: '56464.56'
      },
      {
        genero: 'masculino',
        origen_recursos: 'kiva',
        sector: 'Urbano',
        tipo_credito: 'Comercial',
        saldo: '4000',
        cap_activo: '653.234',
        cap_ndevenga: '856.542',
        cartera_riesgo: '124748',
        cap_vencido: '674687.928'
      },
      {
        genero: 'juridico',
        origen_recursos: 'extra',
        sector: 'Urbano',
        tipo_credito: 'Comercial',
        saldo: '100',
        cap_activo: '100',
        cap_ndevenga: '100',
        cartera_riesgo: '100',
        cap_vencido: '100'
        }
    ]
  end
end
