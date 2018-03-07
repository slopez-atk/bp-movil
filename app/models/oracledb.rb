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
    NVL((select total from CRED_TABLA_AMORTIZA_CONTRATADA WHERE NUMERO_CREDITO=ct.NUMERO_CREDITO
                      and orden in (select max(orden) from cred_tabla_amortiza_contratada
                      where FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      and NUMERO_CREDITO=ct.NUMERO_CREDITO)
                      AND FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      ),0) saldo,
    nvl((select sum(valor) from cred_cabecera_pagos_credito where numero_credito=ct.numero_credito and
    trunc(FECHA) BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
    ),0)pago_realizado,
    (select max(trunc(fecha)) from cred_cabecera_pagos_credito where numero_credito=ct.numero_credito and
    trunc(FECHA) BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
    )fecha_pago_realizado,
    (case
                 when (select total from CRED_TABLA_AMORTIZA_CONTRATADA WHERE NUMERO_CREDITO=ct.NUMERO_CREDITO
                      and orden in (select max(orden) from cred_tabla_amortiza_contratada
                      where FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      and NUMERO_CREDITO=ct.NUMERO_CREDITO)
                      AND FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      )=(select sum(valor) from cred_cabecera_pagos_credito where numero_credito=ct.numero_credito and
                      trunc(FECHA) BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      ) then ((select total from CRED_TABLA_AMORTIZA_CONTRATADA WHERE NUMERO_CREDITO=ct.NUMERO_CREDITO
                      and orden in (select max(orden) from cred_tabla_amortiza_contratada
                      where FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      and NUMERO_CREDITO=ct.NUMERO_CREDITO)
                      AND FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      ))
                when ((select sum(valor) from cred_cabecera_pagos_credito where numero_credito=ct.numero_credito and
                      trunc(FECHA) BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      )<(select total from CRED_TABLA_AMORTIZA_CONTRATADA WHERE NUMERO_CREDITO=ct.NUMERO_CREDITO
                      and orden in (select max(orden) from cred_tabla_amortiza_contratada
                      where FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      and NUMERO_CREDITO=ct.NUMERO_CREDITO)
                      AND FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      )) then ((select sum(valor) from cred_cabecera_pagos_credito where numero_credito=ct.numero_credito and
                      trunc(FECHA) BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')))

                 when (select sum(valor) from cred_cabecera_pagos_credito where numero_credito=ct.numero_credito and
                      trunc(FECHA) BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy'))>
                      ((select total from CRED_TABLA_AMORTIZA_CONTRATADA WHERE NUMERO_CREDITO=ct.NUMERO_CREDITO
                      and orden in (select max(orden) from cred_tabla_amortiza_contratada
                      where FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      and NUMERO_CREDITO=ct.NUMERO_CREDITO)
                      AND FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      ))
                      then

                      (select total from CRED_TABLA_AMORTIZA_CONTRATADA WHERE NUMERO_CREDITO=ct.NUMERO_CREDITO
                      and orden in (select max(orden) from cred_tabla_amortiza_contratada
                      where FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      and NUMERO_CREDITO=ct.NUMERO_CREDITO)
                      AND FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      )
                else 0 end )valor_recuperado,


                (case
                 when (select total from CRED_TABLA_AMORTIZA_CONTRATADA WHERE NUMERO_CREDITO=ct.NUMERO_CREDITO
                      and orden in (select max(orden) from cred_tabla_amortiza_contratada
                      where FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      and NUMERO_CREDITO=ct.NUMERO_CREDITO)
                      AND FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      )=(select sum(valor) from cred_cabecera_pagos_credito where numero_credito=ct.numero_credito and
                      trunc(FECHA) BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      ) then ('PR = VC')
                when ((select sum(valor) from cred_cabecera_pagos_credito where numero_credito=ct.numero_credito and
                      trunc(FECHA) BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      )<(select total from CRED_TABLA_AMORTIZA_CONTRATADA WHERE NUMERO_CREDITO=ct.NUMERO_CREDITO
                      and orden in (select max(orden) from cred_tabla_amortiza_contratada
                      where FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      and NUMERO_CREDITO=ct.NUMERO_CREDITO)
                      AND FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      )) then ('PR < VC')

                 when (select sum(valor) from cred_cabecera_pagos_credito where numero_credito=ct.numero_credito and
                      trunc(FECHA) BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy'))>
                      ((select total from CRED_TABLA_AMORTIZA_CONTRATADA WHERE NUMERO_CREDITO=ct.NUMERO_CREDITO
                      and orden in (select max(orden) from cred_tabla_amortiza_contratada
                      where FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      and NUMERO_CREDITO=ct.NUMERO_CREDITO)
                      AND FECHA BETWEEN to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy') AND to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
                      ))
                      then
                      ('PR > VC')
                else 'NO PAGO' end)condicion_pago,


                (select min(fecfincal) from cred_tabla_amortiza_variable where numero_credito=ct.numero_credito and estadocal='P')fecha_prox_pago_variable,

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
      results.each do |row|
        row["fecha_concesion"] = row["fecha_concesion"].to_date.strftime('%d-%m-%Y')
        row["fecha_prox_pago_variable"] = row["fecha_prox_pago_variable"].to_date.strftime('%d-%m-%Y')
        row["fecha"] = row["fecha"].to_date.strftime('%d-%m-%Y')
      end
      return results
    else
      return {}
    end
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

  def self.obtener_creditos_de_asesor nombre, diaInicio, diaFin, fecha, agencia

    if agencia === "Servimovil"
      agencia = "Servim"
    end

    puts agencia
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
             ) like upper ('%#{nombre}%')
              and (SELECT MIN(SS.DESCRIPCION) FROM SIFV_SUCURSALES SS WHERE SS.CODIGO_SUCURSAL = cc.CODIGO_SUCURSAL) like ('%#{agencia}%')
                 GROUP BY CC.NUMERO_CREDITO, CH.ESTADO_CARSEG, CC.OBS_DESCRE
      )TH
       GROUP BY TH.NUMERO_CREDITO, TH.COD_GRUPO, TH.COD_PRODUCTO, TH.OF_CRED, TH.COD_USUARIO, TH.COD_SUCURSAL, TH.COD_SOCIO,TH.OBSERVACIONES,th.codigo_cicn

    ) TH1
    where TH1.DIASMORA_PD between #{diaInicio.to_i} and #{diaFin.to_i}
    ")


    if results.present?
      results.each do |row|
        row["fecha_ingreso"] = row["fecha_ingreso"].to_date.strftime('%d-%m-%Y')
        row["fecha_concesion"] = row["fecha_concesion"].to_date.strftime('%d-%m-%Y')
        row["fecha_vencimiento"] = row["fecha_vencimiento"].to_date.strftime('%d-%m-%Y')
      end
      return results
    else
      return {}
    end
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
      (select inst_descripcion from socios_instruccion where inst_codigo = th1.instruc) nivel_de_instruccion,
    th1.CALIFICACION_INICIAL,
    TH1.CALIFICACION_FINAL,
    TH1.DIASMORA_PD,
    TH1.NOM_GRUPO,
    (SELECT descripcion FROM CRED_ACT_ECO_DEST_CRE A WHERE A.CODIGO =substr(TH1.activ,0,3) AND A.NIVEL=1)AE_sector,
    (SELECT descripcion FROM CRED_ACT_ECO_DEST_CRE A WHERE A.CODIGO =substr(TH1.activ,0,5) AND A.NIVEL=3)AE_subsector,
    --select * from CRED_ACT_ECO_DEST_CRE
    (SELECT descripcion FROM CRED_ACT_ECO_DEST_CRE A WHERE A.CODIGO =TH1.activ AND A.NIVEL=5)DESTINO_CREDITO,
    TH1.CODIGO_PERIOC,
    (TH1.NUM_CUOTAS) AS CUOTAS_CREDITO,
    (select count(*) from cred_tabla_amortiza_variable where estadocal='P' and numero_credito=th1.numero_credito) as cuotas_p,
    (case when (select count(*) from cred_tabla_amortiza_variable where estadocal in ('C') and numero_credito=th1.numero_credito)=0 then 1
    else (select max(rownum)+1 from cred_tabla_amortiza_variable ct where estadocal='C' and numero_credito=th1.numero_credito) end
    )cuota_vencida,
    TH1.VAL_CREDITO,

    TH1.CAP_ACTIVO,
    TH1.CAP_NDEVENGA,
    TH1.CAP_VENCIDO,
    (TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)CARTERA_RIESGO,
    TH1.CAP_SALDO,

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
     (SELECT substr(min(mcli_lugar_dir),2,6) from socios_direcciones where codigo_socio=th1.socio)codigo_parroquia,
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
                            --select * from CRED_HISTORIAL_REC_CARTERA
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
             --and cc.fecha_credito>=TO_DATE('01/10/2016','DD/MM/YYYY')
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
      results.each do |row|
        row["fecha_concesion"] = row["fecha_concesion"].to_date.strftime('%d-%m-%Y')
        row["fecha_vencimiento"] = row["fecha_vencimiento"].to_date.strftime('%d-%m-%Y')
      end
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
      results.each do |row|
        row["fecha_concesion"] = row["fecha_concesion"].to_date.strftime('%d-%m-%Y')
      end
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
    return data
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
    th1.nom_grupo tipo_credito,
    --CASE WHEN TH1.TIP_ID = 'R' THEN TH1.EMPRESA ELSE TH1.NOMBRE END NOMBRE,
    TH1.NUMERO_CREDITO CREDITO,
    (select tt.provision_especifica from temp_c02 tt where tt.numero_operacion=th1.numero_credito)provision_requerida,
    --TH1.CODIGO_PERIOC,
     (select descripcion  from socios_profesiones  sp, socios so
     where sp.codigo_profesion=so.codigo_profesion and so.codigo_socio=th1.socio ) PROFESION,

    (
    SELECT MAX(DESCRIPCION) from Sifv_Parroquias d,socios_direcciones sd
           WHERE d.codigo_pais = substr(sd.mcli_lugar_dir,1,2)
           and d.codigo_provincia = substr(sd.mcli_lugar_dir,3,2)
           and d.codigo_ciudad = substr(sd.mcli_lugar_dir,5,2)
           and d.codigo_parroquia = substr(sd.mcli_lugar_dir,7,2)
           and sd.codigo_socio=TH1.SOCIO
     ) AS PARROQUIA,
     (SELECT substr(min(mcli_lugar_dir),2,6) from socios_direcciones where codigo_socio=th1.socio)codigo_parroquia,
     (select max(descripcion) from capta_cab_grupos_organizados co, socios_solisoc_datos_generales sdg
             where co.codigo_empresa_gruporg=sdg.codigo_gruporg and sdg.codigo_socio=th1.socio)grupo_org,
     (case
     when substr((select max(descripcion) from capta_cab_grupos_organizados co, socios_solisoc_datos_generales sdg
             where co.codigo_empresa_gruporg=sdg.codigo_gruporg and sdg.codigo_socio=th1.socio),0,2)='GS' then 'SOLIDARIO'
     when substr((select max(descripcion) from capta_cab_grupos_organizados co, socios_solisoc_datos_generales sdg
             where co.codigo_empresa_gruporg=sdg.codigo_gruporg and sdg.codigo_socio=th1.socio),0,2)='AS' then 'ASOCIATIVO'
     WHEN substr((select max(descripcion) from capta_cab_grupos_organizados co, socios_solisoc_datos_generales sdg
             where co.codigo_empresa_gruporg=sdg.codigo_gruporg and sdg.codigo_socio=th1.socio),0,4)='IN B' then 'IN BONO'
     WHEN substr((select max(descripcion) from capta_cab_grupos_organizados co, socios_solisoc_datos_generales sdg
             where co.codigo_empresa_gruporg=sdg.codigo_gruporg and sdg.codigo_socio=th1.socio),0,4)='IN I' then 'INDEPENDIENTE'
     WHEN substr((select max(descripcion) from capta_cab_grupos_organizados co, socios_solisoc_datos_generales sdg
             where co.codigo_empresa_gruporg=sdg.codigo_gruporg and sdg.codigo_socio=th1.socio),0,2)='BC' then 'BANCA COMUNAL'
     else 'REVISAR' end         )metodologia,
    -- instruccion
    (select descripcion from socios_instrucciones  si, socios so where so.codigo_socio=th1.socio and si.codigo_instruccion=so.codigo_instruccion )instruccion,
    -- estado_civil
    (case (select codigo_estado_civil from socios where codigo_socio=th1.socio)
          when 1 then 'Casado'
          when 2 then 'Soltero'
          when 3 then 'Divorciado'
          when 4 then 'Viudo'
          when 5 then 'Union Libre'
          else 'No Aplica'
  end) as ESTADO_CIVIL,
    -- actividad
(SELECT MAX(DESCRIPCION) FROM CRED_ACT_ECO_DEST_CRE WHERE CODIGO = (SELECT MAX(AE.CODIGO_SECTOR)
FROM SOCIOS_TRABAJO_PRINCIPAL AE WHERE TH1.SOCIO = AE.CODIGO_SOCIO)) ACTIVIDAD,
    (select sueldo_promedio_mensual from socios where codigo_socio=th1.socio)ingreso_mensual,

     (case when (select sueldo_promedio_mensual from socios where codigo_socio=th1.socio)<=400 then '1'
          when (select sueldo_promedio_mensual from socios where codigo_socio=th1.socio) between 400 and 800 then '2'
          when (select sueldo_promedio_mensual from socios where codigo_socio=th1.socio)>800 then '3'
    else 'NO INFORMA' end
    )ing_mensual_tipologia,
    -- ingreso_promedio

    --(TH1.NUM_CUOTAS) AS CUOTAS_CREDITO,
    --TH1.TIP_ID,
    --TH1.CEDULA,
    case TH1.GENERO when 'M' then 'MASCULINO' when 'F' then 'FEMENINO' else 'JURIDICO' end genero,
    TRUNC((SYSDATE-TH1.EDAD)/365.25)EDAD,
    (case
         when TRUNC((SYSDATE-TH1.EDAD)/365.25)>=0 and TRUNC((SYSDATE-TH1.EDAD)/365.25)<= 18 then '0-18'
         when TRUNC((SYSDATE-TH1.EDAD)/365.25)>18 and TRUNC((SYSDATE-TH1.EDAD)/365.25)<= 25 then '19-25'
         when TRUNC((SYSDATE-TH1.EDAD)/365.25)>25 and TRUNC((SYSDATE-TH1.EDAD)/365.25)<= 30 then '26-30'
         when TRUNC((SYSDATE-TH1.EDAD)/365.25)>30 and TRUNC((SYSDATE-TH1.EDAD)/365.25)<= 35 then '31-35'
         when TRUNC((SYSDATE-TH1.EDAD)/365.25)>35 and TRUNC((SYSDATE-TH1.EDAD)/365.25)<= 40 then '36-40'
         when TRUNC((SYSDATE-TH1.EDAD)/365.25)>40 and TRUNC((SYSDATE-TH1.EDAD)/365.25)<= 45 then '41-45'
         when TRUNC((SYSDATE-TH1.EDAD)/365.25)>45 and TRUNC((SYSDATE-TH1.EDAD)/365.25)<= 50 then '46-50'
         when TRUNC((SYSDATE-TH1.EDAD)/365.25)>50 and TRUNC((SYSDATE-TH1.EDAD)/365.25)<= 55 then '51-55'
         when TRUNC((SYSDATE-TH1.EDAD)/365.25)>55 and TRUNC((SYSDATE-TH1.EDAD)/365.25)<= 60 then '56-60'
         when TRUNC((SYSDATE-TH1.EDAD)/365.25)>60 then '> 60'
         else 'REVISA' end)rango_edad,
    --th1.edad fecha_nacimiento,
   -- TH1.CALIFICACION,
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
    FECHA_VENCIMIENTO
    (select max(j.fecfincal) from cred_tabla_amortiza_variable j
    where j.ordencal = (select max(i.ordencal)  from cred_tabla_amortiza_variable i
                        where i.numero_credito = TH1.NUMERO_CREDITO)
      and j.numero_credito = TH1.NUMERO_CREDITO) as FECHA_VENCIMIENTO,*/
    (select SUM(ROUND(NVL(CAPITALCAL,0),2) + ROUND(NVL(INTERESCAL,0),2) + ROUND(NVL(MORACAL,0),2) +
              ROUND(CASE WHEN trunc(fecinical)>trunc(sysdate) THEN 0 ELSE NVL(rubroscal,0) END,2)) from CRED_TABLA_AMORTIZA_VARIABLE A
                         where a.numero_credito=TH1.numero_credito
                         and estadocal='P')valor_cancela,
    TH1.DIASMORA_PD
    /*TH1.SUCURSAL OFICINA,
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
             )ASESOR*/


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
              and (SELECT MIN(SS.DESCRIPCION) FROM SIFV_SUCURSALES SS WHERE SS.CODIGO_SUCURSAL = cc.CODIGO_SUCURSAL) like ('%#{agencia}%')
                 GROUP BY CC.NUMERO_CREDITO, CH.ESTADO_CARSEG, CC.OBS_DESCRE
      )TH
       GROUP BY TH.NUMERO_CREDITO, TH.COD_GRUPO, TH.COD_PRODUCTO, TH.OF_CRED, TH.COD_USUARIO, TH.COD_SUCURSAL, TH.COD_SOCIO,TH.OBSERVACIONES,th.codigo_cicn

    ) TH1
    where TH1.DIASMORA_PD between #{dia_inicio.to_i} and #{dia_fin.to_i}
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
        metodologia: 'metodo1',
        monto_real: '1233.234',
        instruccion: 'Superior',
        estado_civil: 'Soltero',
        rango_edad: '+60',
        ing_mensual_tipologia: '2000'

      },
      {
        genero: 'femenino',
        origen_recursos: 'triods',
        sector: 'Urbano',
        tipo_credito: 'Consumo',
        metodologia: 'metodo1',
        monto_real: '23452.234',
        instruccion: 'Superior',
        estado_civil: 'Casado',
        rango_edad: '+64',
        ing_mensual_tipologia: '2000'
      },
      {
        genero: 'juridico',
        origen_recursos: 'kiva',
        sector: 'Rural',
        tipo_credito: 'Comercial',
        metodologia: 'metodo2',
        monto_real: '23452.234',
        instruccion: 'Superior',
        estado_civil: 'Soltero',
        rango_edad: '+60',
        ing_mensual_tipologia: '2000'
      },
      {
        genero: 'masculino',
        origen_recursos: 'Triods',
        sector: 'Urbano',
        tipo_credito: 'Comercial',
        metodologia: 'metodo2',
        monto_real: '23452.234',
        instruccion: 'Superior',
        estado_civil: 'Soltero',
        rango_edad: '+60',
        ing_mensual_tipologia: '2000'
      },
      {
          genero: 'juridico',
          origen_recursos: 'extra',
          sector: 'Urbano',
          tipo_credito: 'Comercial',
          metodologia: 'metodo3',
          monto_real: '23452.234',
          instruccion: 'Superior',
          estado_civil: 'Soltero',
          rango_edad: '+60',
          ing_mensual_tipologia: '2000'
      },{
          genero: 'xxxxx',
          origen_recursos: 'extra',
          sector: 'Urbano',
          tipo_credito: 'Comercial',
          metodologia: 'metodo3',
          monto_real: '3242.234',
          instruccion: 'Superior',
          estado_civil: 'Soltero',
          rango_edad: '+60',
          ing_mensual_tipologia: '2000'
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
    SELECT --CODIGO_SUCURSAL,

    (select sing_fecsoli from socios_solisoc_datos_generales where codigo_socio=cp.codigo_socio )FECHA_INGRESO,

    (select descripcion_grupo from cred_grupo_segmentos_credito cg where cg.codigo_grupo=cp.codigo_grupo)tipo_credito,
        (select MAX(descripcion) from cred_tipos_recursos_economicos where codigo = cp.codigo_orirec) as ORIGEN_RECURSOS,


    CODIGO_SOCIO,
    cp.numero_credito CREDITO,

    (select descripcion  from socios_profesiones  sp, socios so
         where sp.codigo_profesion=so.codigo_profesion and so.codigo_socio=cp.codigo_socio ) PROFESION,
    nvl((select tipo_sector from socios_solisoc_datos_generales where codigo_socio=cp.codigo_socio),'NV')sector,
        (
        SELECT MAX(DESCRIPCION) from Sifv_Parroquias d,socios_direcciones sd
               WHERE d.codigo_pais = substr(sd.mcli_lugar_dir,1,2)
               and d.codigo_provincia = substr(sd.mcli_lugar_dir,3,2)
               and d.codigo_ciudad = substr(sd.mcli_lugar_dir,5,2)
               and d.codigo_parroquia = substr(sd.mcli_lugar_dir,7,2)
               and sd.codigo_socio=cp.codigo_socio
         ) AS PARROQUIA,
         (SELECT substr(min(mcli_lugar_dir),2,6) from socios_direcciones where codigo_socio=cp.codigo_socio)codigo_parroquia,
         (select max(descripcion) from capta_cab_grupos_organizados co, socios_solisoc_datos_generales sdg
                 where co.codigo_empresa_gruporg=sdg.codigo_gruporg and sdg.codigo_socio=cp.codigo_socio)grupo_org,
         (case
         when substr((select max(descripcion) from capta_cab_grupos_organizados co, socios_solisoc_datos_generales sdg
                 where co.codigo_empresa_gruporg=sdg.codigo_gruporg and sdg.codigo_socio=cp.codigo_socio),0,2)='GS' then 'SOLIDARIO'
         when substr((select max(descripcion) from capta_cab_grupos_organizados co, socios_solisoc_datos_generales sdg
                 where co.codigo_empresa_gruporg=sdg.codigo_gruporg and sdg.codigo_socio=cp.codigo_socio),0,2)='Gs' then 'SOLIDARIO'
         when substr((select max(descripcion) from capta_cab_grupos_organizados co, socios_solisoc_datos_generales sdg
                 where co.codigo_empresa_gruporg=sdg.codigo_gruporg and sdg.codigo_socio=cp.codigo_socio),0,2)='AS' then 'ASOCIATIVO'
         WHEN substr((select max(descripcion) from capta_cab_grupos_organizados co, socios_solisoc_datos_generales sdg
                 where co.codigo_empresa_gruporg=sdg.codigo_gruporg and sdg.codigo_socio=cp.codigo_socio),0,4)='IN B' then 'IN BONO'
         WHEN substr((select max(descripcion) from capta_cab_grupos_organizados co, socios_solisoc_datos_generales sdg
                 where co.codigo_empresa_gruporg=sdg.codigo_gruporg and sdg.codigo_socio=cp.codigo_socio),0,4)='IN I' then 'INDEPENDIENTE'
         WHEN substr((select max(descripcion) from capta_cab_grupos_organizados co, socios_solisoc_datos_generales sdg
                 where co.codigo_empresa_gruporg=sdg.codigo_gruporg and sdg.codigo_socio=cp.codigo_socio),0,2)='BC' then 'BANCA COMUNAL'
         else 'REVISAR' end         )metodologia,
        -- instruccion
        (select descripcion from socios_instrucciones  si, socios so where so.codigo_socio=cp.codigo_socio and si.codigo_instruccion=so.codigo_instruccion )instruccion,
        -- estado_civil
        (case (select codigo_estado_civil from socios where codigo_socio=cp.codigo_socio)
              when 1 then 'Casado'
              when 2 then 'Soltero'
              when 3 then 'Divorciado'
              when 4 then 'Viudo'
              when 5 then 'Union Libre'
              else 'No Aplica'
      end) as ESTADO_CIVIL,
      (case when (select sueldo_promedio_mensual from socios where codigo_socio=cp.codigo_socio)<=400 then '1'
              when (select sueldo_promedio_mensual from socios where codigo_socio=cp.codigo_socio) between 400 and 800 then '2'
              when (select sueldo_promedio_mensual from socios where codigo_socio=cp.codigo_socio)>800 then '3'
        else 'NO INFORMA' end
        )ing_mensual_tipologia,
        -- actividad
    (SELECT MAX(DESCRIPCION) FROM CRED_ACT_ECO_DEST_CRE WHERE CODIGO = (SELECT MAX(AE.CODIGO_SECTOR)
    FROM SOCIOS_TRABAJO_PRINCIPAL AE WHERE cp.codigo_socio = AE.CODIGO_SOCIO)) ACTIVIDAD,
        (select sueldo_promedio_mensual from socios where codigo_socio=cp.codigo_socio)ingreso_mensual,
        -- ingreso_promedio

        --(TH1.NUM_CUOTAS) AS CUOTAS_CREDITO,
        --TH1.TIP_ID,
        --TH1.CEDULA,
        case (select mcli_sexo from socios where codigo_socio=cp.codigo_socio) when 'M' then 'MASCULINO' when 'F' then 'FEMENINO' else 'JURIDICO' end genero,
        TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)EDAD,
        (case
             when TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)>=0 and TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)<= 18 then '0-18'
             when TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)>18 and TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)<= 25 then '19-25'
             when TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)>25 and TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)<= 30 then '26-30'
             when TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)>30 and TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)<= 35 then '31-35'
             when TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)>35 and TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)<= 40 then '36-40'
             when TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)>40 and TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)<= 45 then '41-45'
             when TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)>45 and TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)<= 50 then '46-50'
             when TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)>50 and TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)<= 55 then '51-55'
             when TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)>55 and TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)<= 60 then '56-60'
             when TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)>60 then '> 60'
             else 'REVISA' end)rango_edad,
             cp.monto_real MONTO_REAL,



    (select descripcion from sifv_sucursales where codigo_sucursal=cp.codigo_sucursal )SUCURSAL,
    (SELECT DESCRIPCION FROM CONF_PRODUCTOS WHERE CODIGO_ACT_FINANCIERA=2 AND CODIGO_PRODUCTO=CP.CODIGO_PRODUCTO) AS DESCRIPCION_PROD,
    FECHA_CREDITO,
    (case ESTADO_CRED when 'L' then 'VIGENTE' else 'CANCELADO' end)ESTADO_CREDITO,
    CAPITAL_PORPAG,
    (case when CP.OFICRE in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                       when CP.OFICRE in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                       when CP.OFICRE in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                       when cp.oficre in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                       when cp.oficre in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                       when cp.oficre in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                       when cp.oficre in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                       when cp.oficre in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                       when cp.oficre in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                       when cp.oficre in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                       when cp.oficre in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                       else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=cp.oficre) end
    )asesor,
    (SELECT TRIM(B.USU_APELLIDOS)||' '||TRIM(B.USU_NOMBRES)FROM SIFV_USUARIOS_SISTEMA B WHERE B.CODIGO_USUARIO = CP.OFICRE) AS cartera_heredada

    FROM CRED_CREDITOS CP
    WHERE TRUNC(FECHA_CREDITO)>=to_date('#{fecha_inicio.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
    AND TRUNC(FECHA_CREDITO)<=to_date('#{fecha_fin.to_date.strftime('%d-%m-%Y')}','dd/mm/yyyy')
    AND (CP.ESTADO_CRED='L' OR CP.ESTADO_CRED='C')
    AND (select descripcion from sifv_sucursales where codigo_sucursal=cp.codigo_sucursal) like ('%#{agencia}%')
    and (case when CP.OFICRE in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
                       when CP.OFICRE in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
                       when CP.OFICRE in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
                       when cp.oficre in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
                       when cp.oficre in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
                       when cp.oficre in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
                       when cp.oficre in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
                       when cp.oficre in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
                       when cp.oficre in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
                       when cp.oficre in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
                       when cp.oficre in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
                       else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=cp.oficre) end
                 ) like upper ('%#{asesor}%')

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
            metodologia: 'metodo1',
            monto_real: '1233.234',
            instruccion: 'Superior',
            estado_civil: 'Soltero',
            rango_edad: '+60',
            ing_mensual_tipologia: '2000'

        },
        {
            genero: 'femenino',
            origen_recursos: 'triods',
            sector: 'Urbano',
            tipo_credito: 'Consumo',
            metodologia: 'metodo1',
            monto_real: '23452.234',
            instruccion: 'Superior',
            estado_civil: 'Casado',
            rango_edad: '+64',
            ing_mensual_tipologia: '2000'
        },
        {
            genero: 'juridico',
            origen_recursos: 'kiva',
            sector: 'Rural',
            tipo_credito: 'Comercial',
            metodologia: 'metodo2',
            monto_real: '23452.234',
            instruccion: 'Superior',
            estado_civil: 'Soltero',
            rango_edad: '+60',
            ing_mensual_tipologia: '2000'
        },
        {
            genero: 'masculino',
            origen_recursos: 'Triods',
            sector: 'Urbano',
            tipo_credito: 'Comercial',
            metodologia: 'metodo2',
            monto_real: '23452.234',
            instruccion: 'Superior',
            estado_civil: 'Soltero',
            rango_edad: '+60',
            ing_mensual_tipologia: '2000'
        },
        {
            genero: 'juridico',
            origen_recursos: 'extra',
            sector: 'Urbano',
            tipo_credito: 'Comercial',
            metodologia: 'metodo3',
            monto_real: '23452.234',
            instruccion: 'Superior',
            estado_civil: 'Soltero',
            rango_edad: '+60',
            ing_mensual_tipologia: '2000'
        },{
            genero: 'xxxxx',
            origen_recursos: 'extra',
            sector: 'Urbano',
            tipo_credito: 'Comercial',
            metodologia: 'metodo3',
            monto_real: '3242.234',
            instruccion: 'Superior',
            estado_civil: 'Soltero',
            rango_edad: '+60',
            ing_mensual_tipologia: '2000'
        }
    ]
  end


  # Creditos Concedidos - Eficiencia de Cartera


  def self.obtener_creditos_concedidos_por_agencia diaInicio, diaFin
    # data = [{sucursal: 'Matriz', creditos_morosos: 354, saldo_capital_pend: 1000.00, numero_creditos: 23, monto_real: 4500.50},
    #         {sucursal: 'La Merced', creditos_morosos: 230, saldo_capital_pend: 2000.00, numero_creditos: 10, monto_real: 5000.50},
    #         {sucursal: 'Movil', creditos_morosos: 600, saldo_capital_pend: 3000.00, numero_creditos: 20, monto_real: 7500.50}]
    # return data;
    results_111 = connection.exec_query("
    select
    tab.sucursal,
    count(tab.numero_credito)creditos_morosos,
    sum(tab.saldo_capital_pend)saldo_capital_pend
    from (
    SELECT
    SUCURSAL,
    (NUMERO_CREDITO),
    (MONTO_REAL),
    (SALDO_CAPITAL_PEND),
    (VALOR_NOTIFICACIONES),
    (VALOR_JUDICIAL),
    (CAPITAL_VENCIDO)
    from (
             SELECT MIN(FECFINCAL) FECFINCAL,
             MAX(CODIGO_SUCURSAL) CODIGO_SUCURSAL,NUMERO_CREDITO,max(codigo_socio) CODIGO_SOCIO,
             MAX(codigo_usuario) CODIGO_USUARIO,MAX(oficre) CODIGO_OFCRED,
             MAX(CANT_SOLI) MONTO_REAL,
             sucursal sucursal, nom_grupo,
             max(origen_recursos) origen_Recursos,
             MAX(CAPITAL_PORPAG) SALDO_CAPITAL_PEND,MAX(NOTIFICACIONES) VALOR_NOTIFICACIONES,MAX(COSTO_JUDICIAL+GESTION_COBRO) VALOR_JUDICIAL,
             SUM(CAP_ORI_CUOTA-CAPITAL_PAGADO) CAPITAL_VENCIDO,
             SUM(TOTAL_DEBE) TOTAL_DEBE,MAX(MCLI_OBSERVAC) MCLI_OBSERVAC,
             MAX(JUDICIAL) JUDICIAL
             FROM (
                       select FECFINCAL,
                       cc.codigo_sucursal,
                       cc.numero_credito,
                       AV.ORDENCAL,
                       cc.codigo_socio,
                       cc.codigo_usuario,
                       cc.oficre,
                       (SELECT descripcion  FROM SIFV_SUCURSALES where codigo_sucursal=cc.codigo_sucursal)sucursal,
                       (SELECT max(descripcion) from CRED_TIPOS_RECURSOS_ECONOMICOS where cc.codigo_orirec=codigo)origen_recursos,
                       (SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = cc.CODIGO_GRUPO ) AS nom_grupo,
                       CC.CANT_SOLI,
                       CC.TOT_DIAS_MORA,
                       CC.TOT_NUM_MORAS,
                       CC.CAPITAL_PORPAG,
                       CC.OBS,CC.JUDICIAL,
                       CC.COSTO_JUDICIAL,
                       CC.GESTION_COBRO,
                       CC.NOTIFICACIONES,
                       (SELECT CAPITAL FROM CRED_TABLA_AMORTIZA_CONTRATADA WHERE NUMERO_CREDITO=cc.numero_credito and orden=av.ordencal) CAP_ORI_CUOTA,
                       NVL((SELECT SUM(DP.CAPITAL) FROM CRED_CABECERA_PAGOS_CREDITO CP,CRED_DETALLE_PAGOS_CREDITO DP
                       WHERE CP.NUMERO_CREDITO=CC.NUMERO_CREDITO AND  CP.NUMERO_CREDITO=DP.NUMERO_CREDITO AND CP.PAGO_NUMERO=DP.PAGO_NUMERO
                       AND ORDEN=AV.ORDENCAL),0) CAPITAL_PAGADO,
                       ROUND(CAPITALCAL+INTERESCAL+MORACAL+RUBROSCAL,2) TOTAL_DEBE,
                       MCLI_OBSERVAC
                       from CRED_TABLA_AMORTIZA_VARIABLE AV,cred_creditos cc,socios s,socios_solisoc_datos_generales sdg
                       where AV.FECFINCAL<=trunc(sysdate+1) and AV.ESTADOCAL='P'
                       and AV.numero_credito=cc.numero_credito and cc.estado_cred='L'
                       and cc.codigo_socio=s.codigo_socio
                       and cc.codigo_socio=sdg.codigo_socio
                   ) TH
                   group by numero_credito,sucursal,nom_grupo,CAPITAL_PORPAG
             )TH1
             where (CASE WHEN trunc(sysdate)-trunc(FecFINCAL)>0 THEN trunc(sysdate)-trunc(FecFINCAL) ELSE 0 END) between #{diaInicio.to_i} and #{diaFin.to_i}
             group by TH1.sucursal,th1.numero_credito,TH1.saldo_capital_pend
    )tab
    group by tab.sucursal
    order by tab.sucursal
    ")

    results_639 = connection.exec_query("
    SELECT TAB.sucursal,count(CREDITO)numero_creditos,
    sum(saldo_cartera)saldo_cartera
    FROM (
        SELECT TH1.CREDITO, TH1.MONTO, TH1.SALDO,
              th1.sucursal Sucursal, TH1.CAP_ACTIVO CAPITAL_ACTIVO,TH1.CAP_NDEVENGA CAPITAL_NO_DEVENGA, TH1.CAP_VENCIDO CAPITAL_VENCIDO,
              (TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)CARTERA_RIESGO,
              TH1.DIASMORA_PD,
              (TH1.CAP_ACTIVO+TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)SALDO_CARTERA,
              (SELECT SUM(SC.CAPITAL) TCAPITAL  FROM CRED_HISTORIAL_REC_CARTERA SC WHERE TRUNC(SC.FGENERA) = to_date('30/11/2017','dd/mm/yyyy'))AS TSALDO
        FROM(
            SELECT
                TH.NUMERO_CREDITO AS CREDITO, MAX(TH.MON_REAL) MONTO,th.sucursal sucursal,
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
                (select descripcion from sifv_sucursales where codigo_sucursal=cc.codigo_sucursal)sucursal
                  FROM CRED_CREDITOS CC, CRED_HISTORIAL_REC_CARTERA CH
                  WHERE CC.NUMERO_CREDITO = CH.NUMERO_CREDITO
                   AND TRUNC(CH.FGENERA) = trunc(sysdate-1)
             GROUP BY CC.NUMERO_CREDITO, CH.ESTADO_CARSEG,cc.codigo_sucursal
            )TH
            GROUP BY TH.NUMERO_CREDITO,th.sucursal
        )TH1
    )TAB
             GROUP BY TAB.sucursal
    ORDER BY TAB.sucursal
    ")


    if results_111.present?
      results_111.each_with_index do |row, index|
        row.stringify_keys!
        results_639[index].stringify_keys!
        temp = Oracledb.buscar_saldo_cartera_agencia results_111[index]["sucursal"], results_639
        results_111[index]["numero_creditos"] = temp[0]
        results_111[index]["saldo_cartera"] = temp[1]
      end
      return results_111
    else
      return {}
    end
  end

  def self.obtener_creditos_concedidos_por_asesor  diaInicio, diaFin
    # data = [{asesor: 'Matriz', creditos_morosos: 354, saldo_capital_pend: 1000.00, numero_creditos: 23, monto_real: 4500.50},
    #         {asesor: 'La Merced', creditos_morosos: 230, saldo_capital_pend: 2000.00, numero_creditos: 10, monto_real: 5000.50},
    #         {asesor: 'Movil', creditos_morosos: 600, saldo_capital_pend: 3000.00, numero_creditos: 20, monto_real: 7500.50}]
    # return data;
    results_111 = connection.exec_query("
    select
    tab.asesor,
    count(tab.numero_credito)creditos_morosos,
    sum(tab.saldo_capital_pend)saldo_capital_pend
    from (
    SELECT
    SUCURSAL,
    asesor,
    (NUMERO_CREDITO),
    (MONTO_REAL),
    (SALDO_CAPITAL_PEND),
    (VALOR_NOTIFICACIONES),
    (VALOR_JUDICIAL),
    (CAPITAL_VENCIDO)
    from (
             SELECT MIN(FECFINCAL) FECFINCAL,
             MAX(CODIGO_SUCURSAL) CODIGO_SUCURSAL,NUMERO_CREDITO,max(codigo_socio) CODIGO_SOCIO,
             MAX(codigo_usuario) CODIGO_USUARIO,MAX(oficre) CODIGO_OFCRED,
             MAX(CANT_SOLI) MONTO_REAL,
             sucursal sucursal, nom_grupo,asesor,
             max(origen_recursos) origen_Recursos,
             MAX(CAPITAL_PORPAG) SALDO_CAPITAL_PEND,MAX(NOTIFICACIONES) VALOR_NOTIFICACIONES,MAX(COSTO_JUDICIAL+GESTION_COBRO) VALOR_JUDICIAL,
             SUM(CAP_ORI_CUOTA-CAPITAL_PAGADO) CAPITAL_VENCIDO,
             SUM(TOTAL_DEBE) TOTAL_DEBE,MAX(MCLI_OBSERVAC) MCLI_OBSERVAC,
             MAX(JUDICIAL) JUDICIAL
             FROM (
                       select FECFINCAL,
                       cc.codigo_sucursal,
                       cc.numero_credito,
                       AV.ORDENCAL,
                       cc.codigo_socio,
                       cc.codigo_usuario,
                       cc.oficre,
                       (SELECT descripcion  FROM SIFV_SUCURSALES where codigo_sucursal=cc.codigo_sucursal)sucursal,
                       (SELECT max(descripcion) from CRED_TIPOS_RECURSOS_ECONOMICOS where cc.codigo_orirec=codigo)origen_recursos,
                       (SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = cc.CODIGO_GRUPO ) AS nom_grupo,
                       -- (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=cc.oficre) Cartera_Heredada,
                       (case when cc.oficre in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
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
                   )asesor,
                       CC.CANT_SOLI,
                       CC.TOT_DIAS_MORA,
                       CC.TOT_NUM_MORAS,
                       CC.CAPITAL_PORPAG,
                       CC.OBS,CC.JUDICIAL,
                       CC.COSTO_JUDICIAL,
                       CC.GESTION_COBRO,
                       CC.NOTIFICACIONES,
                       (SELECT CAPITAL FROM CRED_TABLA_AMORTIZA_CONTRATADA WHERE NUMERO_CREDITO=cc.numero_credito and orden=av.ordencal) CAP_ORI_CUOTA,
                       NVL((SELECT SUM(DP.CAPITAL) FROM CRED_CABECERA_PAGOS_CREDITO CP,CRED_DETALLE_PAGOS_CREDITO DP
                       WHERE CP.NUMERO_CREDITO=CC.NUMERO_CREDITO AND  CP.NUMERO_CREDITO=DP.NUMERO_CREDITO AND CP.PAGO_NUMERO=DP.PAGO_NUMERO
                       AND ORDEN=AV.ORDENCAL),0) CAPITAL_PAGADO,
                       ROUND(CAPITALCAL+INTERESCAL+MORACAL+RUBROSCAL,2) TOTAL_DEBE,
                       MCLI_OBSERVAC
                       from CRED_TABLA_AMORTIZA_VARIABLE AV,cred_creditos cc,socios s,socios_solisoc_datos_generales sdg
                       where AV.FECFINCAL<=trunc(sysdate+1) and AV.ESTADOCAL='P'
                       and AV.numero_credito=cc.numero_credito and cc.estado_cred='L'
                       and cc.codigo_socio=s.codigo_socio
                       and cc.codigo_socio=sdg.codigo_socio
                   ) TH
                   group by numero_credito,asesor,nom_grupo,CAPITAL_PORPAG,sucursal
             )TH1
             where (CASE WHEN trunc(sysdate)-trunc(FecFINCAL)>0 THEN trunc(sysdate)-trunc(FecFINCAL) ELSE 0 END) between #{diaInicio.to_i} and #{diaFin.to_i}
             group by TH1.asesor,th1.numero_credito,TH1.saldo_capital_pend
    )tab
    group by tab.asesor
    order by tab.asesor
    ")

    results_639 = connection.exec_query("
    SELECT TAB.ASESORES,count(CREDITO)numero_creditos,
    sum(saldo_cartera)saldo_cartera
    FROM (
        SELECT TH1.CREDITO, TH1.MONTO, TH1.SALDO,
              th1.asesor ASESORES, TH1.CAP_ACTIVO CAPITAL_ACTIVO,TH1.CAP_NDEVENGA CAPITAL_NO_DEVENGA, TH1.CAP_VENCIDO CAPITAL_VENCIDO,
              (TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)CARTERA_RIESGO,
              TH1.DIASMORA_PD,
              (TH1.CAP_ACTIVO+TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)SALDO_CARTERA,
              (SELECT SUM(SC.CAPITAL) TCAPITAL  FROM CRED_HISTORIAL_REC_CARTERA SC WHERE TRUNC(SC.FGENERA) = to_date('30/11/2017','dd/mm/yyyy'))AS TSALDO
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
                   AND TRUNC(CH.FGENERA) = trunc(sysdate-1)


             GROUP BY CC.NUMERO_CREDITO, CH.ESTADO_CARSEG
            )TH


            GROUP BY TH.NUMERO_CREDITO,th.asesor
        )TH1
    )TAB

             GROUP BY TAB.ASESORES
    ORDER BY TAB.ASESORES
    ")
    if results_111.present?
      results_111.each_with_index do |row, index|
        row.stringify_keys!
        results_639[index].stringify_keys!
        temp = Oracledb.buscar_saldo_cartera_asesor results_111[index]["asesor"], results_639
        results_111[index]["numero_creditos"] = temp[0]
        results_111[index]["saldo_cartera"] = temp[1]
      end
      return results_111
    else
      return {}
    end



  end

  def self.obtener_creditos_concedidos_por_grupo_credito  diaInicio, diaFin
    # data = [{grupo_credito: 'Matriz', creditos_morosos: 354, saldo_capital_pend: 1000.00, numero_creditos: 23, monto_real: 4500.50},
    #         {grupo_credito: 'La Merced', creditos_morosos: 230, saldo_capital_pend: 2000.00, numero_creditos: 10, monto_real: 5000.50},
    #         {grupo_credito: 'Movil', creditos_morosos: 600, saldo_capital_pend: 3000.00, numero_creditos: 20, monto_real: 7500.50}]
    # return data;
    results_111 = connection.exec_query("
    select
    tab.nom_grupo grupo_credito,
    count(tab.numero_credito)creditos_morosos,
    sum(tab.saldo_capital_pend)saldo_capital_pend
    from (
    SELECT
    SUCURSAL,
    asesor,
    (NUMERO_CREDITO),
    (nom_grupo),
    (MONTO_REAL),
    (SALDO_CAPITAL_PEND),
    (VALOR_NOTIFICACIONES),
    (VALOR_JUDICIAL),
    (CAPITAL_VENCIDO)
    from (
             SELECT MIN(FECFINCAL) FECFINCAL,
             MAX(CODIGO_SUCURSAL) CODIGO_SUCURSAL,NUMERO_CREDITO,max(codigo_socio) CODIGO_SOCIO,
             MAX(codigo_usuario) CODIGO_USUARIO,MAX(oficre) CODIGO_OFCRED,
             MAX(CANT_SOLI) MONTO_REAL,
             sucursal sucursal, nom_grupo,asesor,
             max(origen_recursos) origen_Recursos,
             MAX(CAPITAL_PORPAG) SALDO_CAPITAL_PEND,MAX(NOTIFICACIONES) VALOR_NOTIFICACIONES,MAX(COSTO_JUDICIAL+GESTION_COBRO) VALOR_JUDICIAL,
             SUM(CAP_ORI_CUOTA-CAPITAL_PAGADO) CAPITAL_VENCIDO,
             SUM(TOTAL_DEBE) TOTAL_DEBE,MAX(MCLI_OBSERVAC) MCLI_OBSERVAC,
             MAX(JUDICIAL) JUDICIAL
             FROM (
                       select FECFINCAL,
                       cc.codigo_sucursal,
                       cc.numero_credito,
                       AV.ORDENCAL,
                       cc.codigo_socio,
                       cc.codigo_usuario,
                       cc.oficre,
                       (SELECT descripcion  FROM SIFV_SUCURSALES where codigo_sucursal=cc.codigo_sucursal)sucursal,
                       (SELECT max(descripcion) from CRED_TIPOS_RECURSOS_ECONOMICOS where cc.codigo_orirec=codigo)origen_recursos,
                       (SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = cc.CODIGO_GRUPO ) AS nom_grupo,
                       -- (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=cc.oficre) Cartera_Heredada,
                       (case when cc.oficre in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
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
                   )asesor,
                       CC.CANT_SOLI,
                       CC.TOT_DIAS_MORA,
                       CC.TOT_NUM_MORAS,
                       CC.CAPITAL_PORPAG,
                       CC.OBS,CC.JUDICIAL,
                       CC.COSTO_JUDICIAL,
                       CC.GESTION_COBRO,
                       CC.NOTIFICACIONES,
                       (SELECT CAPITAL FROM CRED_TABLA_AMORTIZA_CONTRATADA WHERE NUMERO_CREDITO=cc.numero_credito and orden=av.ordencal) CAP_ORI_CUOTA,
                       NVL((SELECT SUM(DP.CAPITAL) FROM CRED_CABECERA_PAGOS_CREDITO CP,CRED_DETALLE_PAGOS_CREDITO DP
                       WHERE CP.NUMERO_CREDITO=CC.NUMERO_CREDITO AND  CP.NUMERO_CREDITO=DP.NUMERO_CREDITO AND CP.PAGO_NUMERO=DP.PAGO_NUMERO
                       AND ORDEN=AV.ORDENCAL),0) CAPITAL_PAGADO,
                       ROUND(CAPITALCAL+INTERESCAL+MORACAL+RUBROSCAL,2) TOTAL_DEBE,
                       MCLI_OBSERVAC
                       from CRED_TABLA_AMORTIZA_VARIABLE AV,cred_creditos cc,socios s,socios_solisoc_datos_generales sdg
                       where AV.FECFINCAL<=trunc(sysdate+1) and AV.ESTADOCAL='P'
                       and AV.numero_credito=cc.numero_credito and cc.estado_cred='L'
                       and cc.codigo_socio=s.codigo_socio
                       and cc.codigo_socio=sdg.codigo_socio
                   ) TH
                   group by numero_credito,asesor,nom_grupo,CAPITAL_PORPAG,sucursal
             )TH1
             where (CASE WHEN trunc(sysdate)-trunc(FecFINCAL)>0 THEN trunc(sysdate)-trunc(FecFINCAL) ELSE 0 END) between #{diaInicio.to_i} and #{diaFin.to_i}
             group by TH1.asesor,th1.numero_credito,TH1.saldo_capital_pend,th1.nom_grupo
    )tab
    group by tab.nom_grupo
    order by tab.nom_grupo
    ")

    results_639 = connection.exec_query("
    SELECT TAB.grupo_credito,count(CREDITO)numero_creditos,
    sum(saldo_cartera)saldo_cartera
    FROM (
        SELECT TH1.CREDITO, TH1.MONTO, TH1.SALDO,
              th1.grupo_credito grupo_credito, TH1.CAP_ACTIVO CAPITAL_ACTIVO,TH1.CAP_NDEVENGA CAPITAL_NO_DEVENGA, TH1.CAP_VENCIDO CAPITAL_VENCIDO,
              (TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)CARTERA_RIESGO,
              TH1.DIASMORA_PD,
              (TH1.CAP_ACTIVO+TH1.CAP_NDEVENGA+TH1.CAP_VENCIDO)SALDO_CARTERA,
              (SELECT SUM(SC.CAPITAL) TCAPITAL  FROM CRED_HISTORIAL_REC_CARTERA SC WHERE TRUNC(SC.FGENERA) = to_date('30/11/2017','dd/mm/yyyy'))AS TSALDO
        FROM(
            SELECT
                TH.NUMERO_CREDITO AS CREDITO, MAX(TH.MON_REAL) MONTO,th.grupo_credito grupo_credito,
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
                (select descripcion_grupo from cred_grupo_segmentos_credito where codigo_grupo=cc.codigo_grupo)grupo_credito
                  FROM CRED_CREDITOS CC, CRED_HISTORIAL_REC_CARTERA CH
                  WHERE CC.NUMERO_CREDITO = CH.NUMERO_CREDITO
                   AND TRUNC(CH.FGENERA) = trunc(sysdate-1)
             GROUP BY CC.NUMERO_CREDITO, CH.ESTADO_CARSEG,cc.codigo_grupo
            )TH
            GROUP BY TH.NUMERO_CREDITO,th.grupo_credito
        )TH1
    )TAB
             GROUP BY TAB.grupo_credito
    ORDER BY TAB.grupo_credito
    ")
    if results_111.present?
      results_111.each_with_index do |row, index|
        row.stringify_keys!
        results_639[index].stringify_keys!
        temp = Oracledb.buscar_saldo_cartera_grupo_credito results_111[index]["grupo_credito"], results_639
        results_111[index]["numero_creditos"] = temp[0]
        results_111[index]["saldo_cartera"] = temp[1]
      end
      return results_111
    else
      return {}
    end
  end


  def self.obtener_creditos_concedidos_de_un_asesor asesor, agencia, grupo_credito, diaInicio, diaFin
    # data = [{socio: 2341, credito: 522, nombre: 'Santy'},
    #         {socio: 323, credito: 576, nombre: 'Dany'}]
    # return data
    if agencia === "Servimovil"
      agencia = "Servimóvil"
    end

    results = connection.exec_query("
    --eficiencia cartera por asesor y dias mora
SELECT
d.codigo_socio,
case when d.sing_tipopersona=1 then mcli_apellido_pat||' '||mcli_apellido_mat||' '||mcli_nombres else mcli_razon_social end NOMBRES,
d.mcli_numero_id CEDULA,
NUMERO_CREDITO,
grupo_org,
(SELECT descripcion  FROM SIFV_SUCURSALES where codigo_sucursal=d.codigo_sucursal) NOMBRE_SUCURSAL,
origen_recursos,
(SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = D.CODIGO_GRUPO ) AS NOM_GRUPO,
CASE WHEN trunc(sysdate)-trunc(FecFINCAL)>0 THEN trunc(sysdate)-trunc(FecFINCAL) ELSE 0 END dias_vencido,

(
 SELECT MAX(DESCRIPCION) FROM SIFV_PROVINCIA D, socios_direcciones sd
   WHERE D.CODIGO_PAIS = substr(sd.mcli_lugar_dir,1,2)
     AND D.CODIGO_PROVINCIA = substr(sd.mcli_lugar_dir,3,2)
     and sd.codigo_socio=d.codigo_socio
)AS PROVINCIA,

(
 SELECT MAX(DESCRIPCION) from Sifv_Ciudades d, socios_direcciones sd
   WHERE d.codigo_pais = substr(sd.mcli_lugar_dir,1,2)
     and d.codigo_provincia = substr(sd.mcli_lugar_dir,3,2)
     and d.codigo_ciudad = substr(sd.mcli_lugar_dir,5,2)
     and sd.codigo_socio=d.codigo_socio
) AS CANTON,
(
 SELECT MAX(DESCRIPCION) from Sifv_Parroquias d,socios_direcciones sd
   WHERE d.codigo_pais = substr(sd.mcli_lugar_dir,1,2)
     and d.codigo_provincia = substr(sd.mcli_lugar_dir,3,2)
     and d.codigo_ciudad = substr(sd.mcli_lugar_dir,5,2)
     and d.codigo_parroquia = substr(sd.mcli_lugar_dir,7,2)
     and sd.codigo_socio=d.codigo_socio
) AS PARROQUIA,
(SELECT max(MCLI_TELEFONOS) FROM SOCIOS_DIRECCIONES where codigo_socio=d.codigo_socio and fecha_ingreso=nvl((select max(fecha_ingreso) from SOCIOS_DIRECCIONES where codigo_socio=d.codigo_socio and rownum=1) ,to_date('01/01/1900','dd/mm/yyyy'))) TELEFONO,
(SELECT max(MCLI_TELEFONO_CELULAR) FROM SOCIOS_DIRECCIONES where codigo_socio=d.codigo_socio and fecha_ingreso=nvl((select max(fecha_ingreso) from SOCIOS_DIRECCIONES where codigo_socio=d.codigo_socio and rownum=1) ,to_date('01/01/1900','dd/mm/yyyy'))) CELULAR,
(select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=d.codigo_ofcred) Cartera_Heredada,
         (case when d.codigo_ofcred in (44,25) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=25)
               when d.codigo_ofcred in (75,67,49) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=49)
               when d.codigo_ofcred in (102,43) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=102)
               when d.codigo_ofcred in (78,37,98,95) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=78)
               when d.codigo_ofcred in (13,14) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=14)
               when d.codigo_ofcred in (7,28) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=7)
               when d.codigo_ofcred in (18,5) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=5)
               when d.codigo_ofcred in (68,6,94,47,88,112) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=94)
               when d.codigo_ofcred in (34,77,38,33) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=34)
               when d.codigo_ofcred in (42,122,89) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=122)
               when d.codigo_ofcred in (114,22,73,108,15,120,19,109,17,121,21,40) then (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=114)
               else (select usu_apellidos || ' ' || usu_nombres from sifv_usuarios_sistema where codigo_usuario=d.codigo_ofcred) end
         )asesor,

(select round(sum(cuen_saldo_disp),2) from capta_cuentas_socios where codigo_socio=d.codigo_socio and codigo_producto=1) as SALDO_DISPONIBLE_AHORROS,
(select round(sum(cuen_saldo_bloqueado),2) from capta_cuentas_socios where codigo_socio=d.codigo_socio and codigo_producto=1) as SALDO_BLOQUEADO_AHORROS,
(select round(sum(cuen_saldo_total),2) from capta_cuentas_socios where codigo_socio=d.codigo_socio and codigo_producto=2) as CERTIFICADOS,
(select round(sum(cuen_saldo_total),2) from capta_cuentas_socios where codigo_socio=d.codigo_socio and codigo_producto=4) as SALDO_ENCAJE,
(select round(sum(cuen_saldo_total),2) from capta_cuentas_socios where codigo_socio=d.codigo_socio and codigo_producto=7) as SALDO_CESANTIA,
MONTO_REAL,
SALDO_CAPITAL_PEND,
(select SUM(ROUND(NVL(CAPITALCAL,0),2) + ROUND(NVL(INTERESCAL,0),2) + ROUND(NVL(MORACAL,0),2) +
          ROUND(CASE WHEN trunc(fecinical)>trunc(sysdate) THEN 0 ELSE NVL(rubroscal,0) END,2)) from CRED_TABLA_AMORTIZA_VARIABLE A
                     where a.numero_credito=d.numero_credito
                     and estadocal='P')valor_cancela,
VALOR_NOTIFICACIONES,
VALOR_JUDICIAL,
CAPITAL_VENCIDO,
FECFINCAL FECHA_VENCE,
(case when FECFINCAL<=trunc(sysdate) then  total_debe+valor_judicial+valor_notificaciones else 0 END)  TOTAL_VENCIDO,
(case when FECFINCAL>trunc(sysdate) then total_debe+valor_judicial+valor_notificaciones else 0 END)   por_vencer_manana,
mcli_observac,
case when judicial='S' then 'Demandado' else ' ' end Estado_Judi,
          (select OBSERVACIONES_R from cred_notificaciones_credito nc where numero_credito=d.numero_credito and numero_notificacion =
          (select max(numero_notificacion) from cred_notificaciones_credito where numero_credito=d.numero_credito)) Notificacion
from (
         SELECT MIN(FECFINCAL) FECFINCAL,MAX(CODIGO_SUCURSAL) CODIGO_SUCURSAL,NUMERO_CREDITO,max(codigo_socio) CODIGO_SOCIO,
         MAX(codigo_usuario) CODIGO_USUARIO,MAX(oficre) CODIGO_OFCRED,MAX(mcli_numero_id) MCLI_NUMERO_ID,MAX(sing_tipopersona) SING_TIPOPERSONA,
         MAX(mcli_apellido_pat) MCLI_APELLIDO_PAT,MAX(mcli_apellido_mat) MCLI_APELLIDO_MAT,MAX(mcli_nombres) MCLI_NOMBRES,MAX(mcli_razon_social) MCLI_RAZON_SOCIAL,MAX(codigo_profesion) CODIGO_PROFESION,
         MAX(CANT_SOLI) MONTO_REAL, grupo_org,
         --GRUPO
         MAX(CODIGO_GRUPO)CODIGO_GRUPO,
         max(origen_recursos) origen_Recursos,
         MAX(CAPITAL_PORPAG) SALDO_CAPITAL_PEND,MAX(NOTIFICACIONES) VALOR_NOTIFICACIONES,MAX(COSTO_JUDICIAL+GESTION_COBRO) VALOR_JUDICIAL,
         SUM(CAP_ORI_CUOTA-CAPITAL_PAGADO) CAPITAL_VENCIDO,SUM(TOT_DIAS_MORA) DIAS_VENCIDO,SUM(TOTAL_DEBE) TOTAL_DEBE,MAX(MCLI_OBSERVAC) MCLI_OBSERVAC,
         MAX(JUDICIAL) JUDICIAL
         FROM (
                   select FECFINCAL,cc.codigo_sucursal,cc.numero_credito,AV.ORDENCAL,cc.codigo_socio,cc.codigo_usuario,
                   cc.oficre,s.mcli_numero_id,sdg.sing_tipopersona,
                  -- (select * from all_all_tables where table_name like ('%REC%') )
                   -- select * from CRED_TIPOS_RECURSOS_ECONOMICOS
                   (SELECT max(descripcion) from CRED_TIPOS_RECURSOS_ECONOMICOS where cc.codigo_orirec=codigo)origen_recursos,
                   mcli_apellido_pat,mcli_apellido_mat,mcli_nombres,mcli_razon_social,codigo_profesion,
                   (select max(descripcion) from capta_cab_grupos_organizados co where co.codigo_empresa_gruporg=sdg.codigo_gruporg)grupo_org,
                   --grupo
                   cc.codigo_grupo,
                   CC.CANT_SOLI,CC.NUM_CUOTAS,CC.TASA_INTERES,CC.TOT_DIAS_MORA,CC.TOT_NUM_MORAS,CC.CAPITAL_PORPAG,CC.OBS,CC.JUDICIAL,CC.COSTO_JUDICIAL, CC.GESTION_COBRO,CC.NOTIFICACIONES,
                   (SELECT CAPITAL FROM CRED_TABLA_AMORTIZA_CONTRATADA WHERE NUMERO_CREDITO=cc.numero_credito and orden=av.ordencal) CAP_ORI_CUOTA,
                   NVL((SELECT SUM(DP.CAPITAL) FROM CRED_CABECERA_PAGOS_CREDITO CP,CRED_DETALLE_PAGOS_CREDITO DP
                   WHERE CP.NUMERO_CREDITO=CC.NUMERO_CREDITO AND  CP.NUMERO_CREDITO=DP.NUMERO_CREDITO AND CP.PAGO_NUMERO=DP.PAGO_NUMERO
                   AND ORDEN=AV.ORDENCAL),0) CAPITAL_PAGADO,
                   ROUND(CAPITALCAL+INTERESCAL+MORACAL+RUBROSCAL,2) TOTAL_DEBE,MCLI_OBSERVAC
                   from CRED_TABLA_AMORTIZA_VARIABLE AV,cred_creditos cc,socios s,socios_solisoc_datos_generales sdg
                   where AV.FECFINCAL<=trunc(sysdate+1) and AV.ESTADOCAL='P'
                   and AV.numero_credito=cc.numero_credito and cc.estado_cred='L'
                   and cc.codigo_socio=s.codigo_socio
                   and cc.codigo_socio=sdg.codigo_socio
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
         and (SELECT descripcion_grupo from CRED_GRUPO_SEGMENTOS_CREDITO where cc.codigo_grupo=codigo_grupo) like ('%#{grupo_credito}%')
   and (SELECT descripcion  FROM SIFV_SUCURSALES where codigo_sucursal=cc.codigo_sucursal)like ('%#{agencia}%')
         ) T
         group by numero_credito,grupo_org
)d
where  (CASE WHEN trunc(sysdate)-trunc(FecFINCAL)>0 THEN trunc(sysdate)-trunc(FecFINCAL) ELSE 0 END) between #{diaInicio.to_i} and #{diaFin.to_i}
order by codigo_socio
    ")

    if results.present?
      results.each do |row|
        row['fecha_vence'] = row['fecha_vence'].to_date.strftime('%d-%m-%Y')
        # row["sector"] = Oracledb.obtenerCodigoSecor row["sector"].to_s
      end
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

  def self.buscar_saldo_cartera_asesor nombre, data
    numero_creditos = 0
    saldo_cartera = 0
    data.each do |row|
      if row["asesores"] == nombre
        numero_creditos = row["numero_creditos"]
        saldo_cartera = row["saldo_cartera"]
      end
    end
    return [numero_creditos, saldo_cartera]
  end

  def self.buscar_saldo_cartera_agencia agencia, data
    numero_creditos = 0
    saldo_cartera = 0
    data.each do |row|
      if row["sucursal"] == agencia
        numero_creditos = row["numero_creditos"]
        saldo_cartera = row["saldo_cartera"]
      end
    end
    return [numero_creditos, saldo_cartera]
  end

  def self.buscar_saldo_cartera_grupo_credito grupo, data
    numero_creditos = 0
    saldo_cartera = 0
    data.each do |row|
      if row["grupo_credito"] == grupo
        numero_creditos = row["numero_creditos"]
        saldo_cartera = row["saldo_cartera"]
      end
    end
    return [numero_creditos, saldo_cartera]
  end

  def self.obtenerCodigoSecor cod_ciu
    return "C" if cod_ciu=="010150"
    return "B" if cod_ciu=="010151"
    return "A" if cod_ciu=="010152"
    return "A" if cod_ciu=="010153"
    return "A" if cod_ciu=="010154"
    return "B" if cod_ciu=="010155"
    return "B" if cod_ciu=="010156"
    return "A" if cod_ciu=="010157"
    return "A" if cod_ciu=="010158"
    return "A" if cod_ciu=="010159"
    return "A" if cod_ciu=="010160"
    return "A" if cod_ciu=="010161"
    return "B" if cod_ciu=="010162"
    return "B" if cod_ciu=="010163"
    return "A" if cod_ciu=="010164"
    return "A" if cod_ciu=="010165"
    return "A" if cod_ciu=="010166"
    return "B" if cod_ciu=="010167"
    return "A" if cod_ciu=="010168"
    return "B" if cod_ciu=="010169"
    return "B" if cod_ciu=="010170"
    return "A" if cod_ciu=="010171"
    return "B" if cod_ciu=="010250"
    return "A" if cod_ciu=="010251"
    return "A" if cod_ciu=="010252"
    return "B" if cod_ciu=="010350"
    return "A" if cod_ciu=="010352"
    return "A" if cod_ciu=="010353"
    return "A" if cod_ciu=="010354"
    return "A" if cod_ciu=="010356"
    return "A" if cod_ciu=="010357"
    return "A" if cod_ciu=="010358"
    return "A" if cod_ciu=="010359"
    return "A" if cod_ciu=="010360"
    return "A" if cod_ciu=="010450"
    return "A" if cod_ciu=="010451"
    return "A" if cod_ciu=="010452"
    return "A" if cod_ciu=="010453"
    return "B" if cod_ciu=="010550"
    return "A" if cod_ciu=="010552"
    return "A" if cod_ciu=="010553"
    return "A" if cod_ciu=="010554"
    return "A" if cod_ciu=="010556"
    return "A" if cod_ciu=="010559"
    return "A" if cod_ciu=="010561"
    return "A" if cod_ciu=="010562"
    return "A" if cod_ciu=="010650"
    return "A" if cod_ciu=="010652"
    return "B" if cod_ciu=="010750"
    return "B" if cod_ciu=="010751"
    return "B" if cod_ciu=="010850"
    return "A" if cod_ciu=="010851"
    return "A" if cod_ciu=="010853"
    return "A" if cod_ciu=="010950"
    return "A" if cod_ciu=="010951"
    return "A" if cod_ciu=="010952"
    return "A" if cod_ciu=="010953"
    return "A" if cod_ciu=="010954"
    return "A" if cod_ciu=="010955"
    return "A" if cod_ciu=="010956"
    return "A" if cod_ciu=="011050"
    return "A" if cod_ciu=="011051"
    return "B" if cod_ciu=="011150"
    return "A" if cod_ciu=="011151"
    return "A" if cod_ciu=="011152"
    return "A" if cod_ciu=="011153"
    return "A" if cod_ciu=="011154"
    return "B" if cod_ciu=="011250"
    return "A" if cod_ciu=="011253"
    return "B" if cod_ciu=="011350"
    return "A" if cod_ciu=="011351"
    return "A" if cod_ciu=="011352"
    return "B" if cod_ciu=="011450"
    return "A" if cod_ciu=="011550"
    return "A" if cod_ciu=="011551"
    return "A" if cod_ciu=="020150"
    return "A" if cod_ciu=="020151"
    return "A" if cod_ciu=="020153"
    return "A" if cod_ciu=="020155"
    return "A" if cod_ciu=="020156"
    return "A" if cod_ciu=="020157"
    return "A" if cod_ciu=="020158"
    return "A" if cod_ciu=="020159"
    return "A" if cod_ciu=="020160"
    return "A" if cod_ciu=="020250"
    return "A" if cod_ciu=="020251"
    return "B" if cod_ciu=="020350"
    return "A" if cod_ciu=="020351"
    return "A" if cod_ciu=="020353"
    return "A" if cod_ciu=="020354"
    return "A" if cod_ciu=="020355"
    return "A" if cod_ciu=="020450"
    return "B" if cod_ciu=="020550"
    return "A" if cod_ciu=="020551"
    return "A" if cod_ciu=="020552"
    return "A" if cod_ciu=="020553"
    return "A" if cod_ciu=="020554"
    return "A" if cod_ciu=="020555"
    return "A" if cod_ciu=="020556"
    return "B" if cod_ciu=="020650"
    return "A" if cod_ciu=="020750"
    return "B" if cod_ciu=="030150"
    return "B" if cod_ciu=="030151"
    return "A" if cod_ciu=="030153"
    return "A" if cod_ciu=="030154"
    return "B" if cod_ciu=="030155"
    return "A" if cod_ciu=="030156"
    return "A" if cod_ciu=="030157"
    return "A" if cod_ciu=="030158"
    return "A" if cod_ciu=="030160"
    return "B" if cod_ciu=="030250"
    return "A" if cod_ciu=="030251"
    return "A" if cod_ciu=="030252"
    return "A" if cod_ciu=="030253"
    return "A" if cod_ciu=="030254"
    return "B" if cod_ciu=="030350"
    return "A" if cod_ciu=="030351"
    return "A" if cod_ciu=="030352"
    return "A" if cod_ciu=="030353"
    return "A" if cod_ciu=="030354"
    return "A" if cod_ciu=="030355"
    return "A" if cod_ciu=="030356"
    return "A" if cod_ciu=="030357"
    return "A" if cod_ciu=="030358"
    return "A" if cod_ciu=="030361"
    return "A" if cod_ciu=="030362"
    return "A" if cod_ciu=="030363"
    return "A" if cod_ciu=="030450"
    return "A" if cod_ciu=="030451"
    return "A" if cod_ciu=="030452"
    return "A" if cod_ciu=="030550"
    return "A" if cod_ciu=="030650"
    return "A" if cod_ciu=="030651"
    return "A" if cod_ciu=="030750"
    return "C" if cod_ciu=="040150"
    return "A" if cod_ciu=="040151"
    return "A" if cod_ciu=="040153"
    return "A" if cod_ciu=="040154"
    return "A" if cod_ciu=="040155"
    return "A" if cod_ciu=="040156"
    return "A" if cod_ciu=="040157"
    return "A" if cod_ciu=="040158"
    return "A" if cod_ciu=="040159"
    return "A" if cod_ciu=="040161"
    return "A" if cod_ciu=="040250"
    return "A" if cod_ciu=="040251"
    return "A" if cod_ciu=="040252"
    return "A" if cod_ciu=="040253"
    return "A" if cod_ciu=="040254"
    return "A" if cod_ciu=="040255"
    return "B" if cod_ciu=="040350"
    return "A" if cod_ciu=="040351"
    return "A" if cod_ciu=="040352"
    return "B" if cod_ciu=="040353"
    return "B" if cod_ciu=="040450"
    return "A" if cod_ciu=="040451"
    return "A" if cod_ciu=="040452"
    return "A" if cod_ciu=="040453"
    return "B" if cod_ciu=="040550"
    return "A" if cod_ciu=="040551"
    return "A" if cod_ciu=="040552"
    return "A" if cod_ciu=="040553"
    return "A" if cod_ciu=="040554"
    return "A" if cod_ciu=="040555"
    return "B" if cod_ciu=="040650"
    return "A" if cod_ciu=="040651"
    return "B" if cod_ciu=="050150"
    return "A" if cod_ciu=="050151"
    return "A" if cod_ciu=="050152"
    return "A" if cod_ciu=="050153"
    return "A" if cod_ciu=="050154"
    return "A" if cod_ciu=="050156"
    return "A" if cod_ciu=="050157"
    return "A" if cod_ciu=="050158"
    return "A" if cod_ciu=="050159"
    return "A" if cod_ciu=="050161"
    return "A" if cod_ciu=="050162"
    return "A" if cod_ciu=="050250"
    return "A" if cod_ciu=="050251"
    return "A" if cod_ciu=="050252"
    return "A" if cod_ciu=="050350"
    return "A" if cod_ciu=="050351"
    return "A" if cod_ciu=="050352"
    return "A" if cod_ciu=="050353"
    return "A" if cod_ciu=="050450"
    return "A" if cod_ciu=="050451"
    return "A" if cod_ciu=="050453"
    return "A" if cod_ciu=="050455"
    return "A" if cod_ciu=="050456"
    return "A" if cod_ciu=="050457"
    return "A" if cod_ciu=="050458"
    return "B" if cod_ciu=="050550"
    return "A" if cod_ciu=="050551"
    return "A" if cod_ciu=="050552"
    return "A" if cod_ciu=="050553"
    return "A" if cod_ciu=="050554"
    return "A" if cod_ciu=="050555"
    return "A" if cod_ciu=="050650"
    return "A" if cod_ciu=="050651"
    return "A" if cod_ciu=="050652"
    return "A" if cod_ciu=="050653"
    return "A" if cod_ciu=="050750"
    return "A" if cod_ciu=="050751"
    return "A" if cod_ciu=="050752"
    return "A" if cod_ciu=="050753"
    return "A" if cod_ciu=="050754"
    return "C" if cod_ciu=="060150"
    return "A" if cod_ciu=="060151"
    return "A" if cod_ciu=="060152"
    return "A" if cod_ciu=="060153"
    return "A" if cod_ciu=="060154"
    return "A" if cod_ciu=="060155"
    return "A" if cod_ciu=="060156"
    return "A" if cod_ciu=="060157"
    return "A" if cod_ciu=="060158"
    return "A" if cod_ciu=="060159"
    return "A" if cod_ciu=="060160"
    return "A" if cod_ciu=="060161"
    return "B" if cod_ciu=="060250"
    return "A" if cod_ciu=="060251"
    return "A" if cod_ciu=="060253"
    return "A" if cod_ciu=="060254"
    return "A" if cod_ciu=="060255"
    return "A" if cod_ciu=="060256"
    return "A" if cod_ciu=="060257"
    return "A" if cod_ciu=="060258"
    return "A" if cod_ciu=="060259"
    return "A" if cod_ciu=="060260"
    return "A" if cod_ciu=="060350"
    return "A" if cod_ciu=="060351"
    return "A" if cod_ciu=="060352"
    return "A" if cod_ciu=="060353"
    return "A" if cod_ciu=="060354"
    return "A" if cod_ciu=="060450"
    return "A" if cod_ciu=="060550"
    return "A" if cod_ciu=="060551"
    return "A" if cod_ciu=="060552"
    return "A" if cod_ciu=="060553"
    return "A" if cod_ciu=="060554"
    return "A" if cod_ciu=="060650"
    return "A" if cod_ciu=="060651"
    return "A" if cod_ciu=="060652"
    return "A" if cod_ciu=="060750"
    return "A" if cod_ciu=="060751"
    return "A" if cod_ciu=="060752"
    return "A" if cod_ciu=="060753"
    return "A" if cod_ciu=="060754"
    return "A" if cod_ciu=="060755"
    return "A" if cod_ciu=="060756"
    return "A" if cod_ciu=="060757"
    return "A" if cod_ciu=="060758"
    return "A" if cod_ciu=="060759"
    return "A" if cod_ciu=="060850"
    return "B" if cod_ciu=="060950"
    return "A" if cod_ciu=="060951"
    return "A" if cod_ciu=="060952"
    return "A" if cod_ciu=="060953"
    return "A" if cod_ciu=="060954"
    return "A" if cod_ciu=="060955"
    return "A" if cod_ciu=="060956"
    return "A" if cod_ciu=="061050"
    return "B" if cod_ciu=="070150"
    return "A" if cod_ciu=="070152"
    return "A" if cod_ciu=="070250"
    return "A" if cod_ciu=="070251"
    return "A" if cod_ciu=="070254"
    return "A" if cod_ciu=="070255"
    return "B" if cod_ciu=="070350"
    return "B" if cod_ciu=="070351"
    return "B" if cod_ciu=="070352"
    return "A" if cod_ciu=="070353"
    return "A" if cod_ciu=="070354"
    return "A" if cod_ciu=="070355"
    return "A" if cod_ciu=="070450"
    return "A" if cod_ciu=="070451"
    return "A" if cod_ciu=="070550"
    return "A" if cod_ciu=="070650"
    return "A" if cod_ciu=="070651"
    return "A" if cod_ciu=="070652"
    return "A" if cod_ciu=="070653"
    return "A" if cod_ciu=="070654"
    return "A" if cod_ciu=="070750"
    return "B" if cod_ciu=="070850"
    return "B" if cod_ciu=="070851"
    return "B" if cod_ciu=="070950"
    return "A" if cod_ciu=="070951"
    return "A" if cod_ciu=="070952"
    return "A" if cod_ciu=="070953"
    return "A" if cod_ciu=="070954"
    return "A" if cod_ciu=="070955"
    return "A" if cod_ciu=="070956"
    return "B" if cod_ciu=="071050"
    return "A" if cod_ciu=="071051"
    return "A" if cod_ciu=="071052"
    return "A" if cod_ciu=="071053"
    return "A" if cod_ciu=="071054"
    return "A" if cod_ciu=="071055"
    return "A" if cod_ciu=="071056"
    return "B" if cod_ciu=="071150"
    return "A" if cod_ciu=="071151"
    return "A" if cod_ciu=="071152"
    return "A" if cod_ciu=="071153"
    return "B" if cod_ciu=="071250"
    return "A" if cod_ciu=="071251"
    return "A" if cod_ciu=="071252"
    return "B" if cod_ciu=="071253"
    return "A" if cod_ciu=="071254"
    return "B" if cod_ciu=="071255"
    return "A" if cod_ciu=="071256"
    return "A" if cod_ciu=="071257"
    return "C" if cod_ciu=="071350"
    return "A" if cod_ciu=="071351"
    return "A" if cod_ciu=="071352"
    return "A" if cod_ciu=="071353"
    return "A" if cod_ciu=="071354"
    return "B" if cod_ciu=="071355"
    return "B" if cod_ciu=="071356"
    return "B" if cod_ciu=="071357"
    return "A" if cod_ciu=="071358"
    return "A" if cod_ciu=="071359"
    return "B" if cod_ciu=="071450"
    return "A" if cod_ciu=="071451"
    return "A" if cod_ciu=="071452"
    return "A" if cod_ciu=="071453"
    return "B" if cod_ciu=="080150"
    return "A" if cod_ciu=="080152"
    return "A" if cod_ciu=="080153"
    return "A" if cod_ciu=="080154"
    return "A" if cod_ciu=="080159"
    return "A" if cod_ciu=="080163"
    return "A" if cod_ciu=="080165"
    return "A" if cod_ciu=="080166"
    return "A" if cod_ciu=="080168"
    return "A" if cod_ciu=="080250"
    return "A" if cod_ciu=="080251"
    return "A" if cod_ciu=="080252"
    return "A" if cod_ciu=="080253"
    return "A" if cod_ciu=="080254"
    return "A" if cod_ciu=="080255"
    return "A" if cod_ciu=="080256"
    return "A" if cod_ciu=="080257"
    return "A" if cod_ciu=="080258"
    return "A" if cod_ciu=="080259"
    return "A" if cod_ciu=="080260"
    return "A" if cod_ciu=="080261"
    return "A" if cod_ciu=="080262"
    return "A" if cod_ciu=="080263"
    return "A" if cod_ciu=="080264"
    return "A" if cod_ciu=="080350"
    return "A" if cod_ciu=="080351"
    return "A" if cod_ciu=="080352"
    return "A" if cod_ciu=="080353"
    return "A" if cod_ciu=="080354"
    return "A" if cod_ciu=="080355"
    return "A" if cod_ciu=="080356"
    return "A" if cod_ciu=="080357"
    return "A" if cod_ciu=="080358"
    return "A" if cod_ciu=="080450"
    return "A" if cod_ciu=="080451"
    return "A" if cod_ciu=="080452"
    return "A" if cod_ciu=="080453"
    return "A" if cod_ciu=="080454"
    return "A" if cod_ciu=="080455"
    return "A" if cod_ciu=="080550"
    return "A" if cod_ciu=="080551"
    return "A" if cod_ciu=="080552"
    return "A" if cod_ciu=="080553"
    return "A" if cod_ciu=="080554"
    return "A" if cod_ciu=="080555"
    return "A" if cod_ciu=="080556"
    return "A" if cod_ciu=="080557"
    return "A" if cod_ciu=="080558"
    return "A" if cod_ciu=="080559"
    return "A" if cod_ciu=="080560"
    return "A" if cod_ciu=="080561"
    return "A" if cod_ciu=="080562"
    return "A" if cod_ciu=="080650"
    return "A" if cod_ciu=="080651"
    return "A" if cod_ciu=="080652"
    return "A" if cod_ciu=="080653"
    return "A" if cod_ciu=="080654"
    return "A" if cod_ciu=="080750"
    return "A" if cod_ciu=="080751"
    return "A" if cod_ciu=="080752"
    return "A" if cod_ciu=="080753"
    return "A" if cod_ciu=="080754"
    return "A" if cod_ciu=="080755"
    return "A" if cod_ciu=="080850"
    return "B" if cod_ciu=="090150"
    return "A" if cod_ciu=="090152"
    return "A" if cod_ciu=="090153"
    return "A" if cod_ciu=="090156"
    return "A" if cod_ciu=="090157"
    return "A" if cod_ciu=="090158"
    return "A" if cod_ciu=="090250"
    return "A" if cod_ciu=="090350"
    return "A" if cod_ciu=="090450"
    return "A" if cod_ciu=="090550"
    return "A" if cod_ciu=="090551"
    return "A" if cod_ciu=="090650"
    return "A" if cod_ciu=="090652"
    return "A" if cod_ciu=="090653"
    return "A" if cod_ciu=="090654"
    return "A" if cod_ciu=="090656"
    return "A" if cod_ciu=="090750"
    return "A" if cod_ciu=="090850"
    return "A" if cod_ciu=="090851"
    return "A" if cod_ciu=="090852"
    return "A" if cod_ciu=="090950"
    return "A" if cod_ciu=="091050"
    return "A" if cod_ciu=="091051"
    return "A" if cod_ciu=="091053"
    return "A" if cod_ciu=="091054"
    return "A" if cod_ciu=="091150"
    return "A" if cod_ciu=="091151"
    return "A" if cod_ciu=="091152"
    return "A" if cod_ciu=="091153"
    return "A" if cod_ciu=="091154"
    return "A" if cod_ciu=="091250"
    return "A" if cod_ciu=="091350"
    return "A" if cod_ciu=="091450"
    return "A" if cod_ciu=="091451"
    return "A" if cod_ciu=="091452"
    return "B" if cod_ciu=="091650"
    return "A" if cod_ciu=="091651"
    return "A" if cod_ciu=="091850"
    return "A" if cod_ciu=="091950"
    return "A" if cod_ciu=="091951"
    return "A" if cod_ciu=="091952"
    return "A" if cod_ciu=="091953"
    return "A" if cod_ciu=="092050"
    return "A" if cod_ciu=="092053"
    return "A" if cod_ciu=="092055"
    return "A" if cod_ciu=="092056"
    return "A" if cod_ciu=="092150"
    return "A" if cod_ciu=="092250"
    return "A" if cod_ciu=="092251"
    return "A" if cod_ciu=="092350"
    return "A" if cod_ciu=="092450"
    return "A" if cod_ciu=="092550"
    return "A" if cod_ciu=="092750"
    return "A" if cod_ciu=="092850"
    return "C" if cod_ciu=="100150"
    return "A" if cod_ciu=="100151"
    return "A" if cod_ciu=="100152"
    return "A" if cod_ciu=="100153"
    return "A" if cod_ciu=="100154"
    return "A" if cod_ciu=="100155"
    return "B" if cod_ciu=="100156"
    return "B" if cod_ciu=="100157"
    return "B" if cod_ciu=="100250"
    return "A" if cod_ciu=="100251"
    return "B" if cod_ciu=="100252"
    return "B" if cod_ciu=="100253"
    return "A" if cod_ciu=="100254"
    return "B" if cod_ciu=="100350"
    return "A" if cod_ciu=="100351"
    return "A" if cod_ciu=="100352"
    return "A" if cod_ciu=="100353"
    return "A" if cod_ciu=="100354"
    return "A" if cod_ciu=="100355"
    return "A" if cod_ciu=="100356"
    return "A" if cod_ciu=="100357"
    return "A" if cod_ciu=="100358"
    return "B" if cod_ciu=="100450"
    return "A" if cod_ciu=="100451"
    return "A" if cod_ciu=="100452"
    return "A" if cod_ciu=="100453"
    return "A" if cod_ciu=="100454"
    return "A" if cod_ciu=="100455"
    return "A" if cod_ciu=="100456"
    return "A" if cod_ciu=="100457"
    return "A" if cod_ciu=="100458"
    return "A" if cod_ciu=="100459"
    return "B" if cod_ciu=="100550"
    return "A" if cod_ciu=="100551"
    return "A" if cod_ciu=="100552"
    return "A" if cod_ciu=="100553"
    return "B" if cod_ciu=="100650"
    return "A" if cod_ciu=="100651"
    return "A" if cod_ciu=="100652"
    return "A" if cod_ciu=="100653"
    return "A" if cod_ciu=="100654"
    return "A" if cod_ciu=="100655"
    return "C" if cod_ciu=="110150"
    return "A" if cod_ciu=="110151"
    return "A" if cod_ciu=="110152"
    return "A" if cod_ciu=="110153"
    return "A" if cod_ciu=="110154"
    return "A" if cod_ciu=="110155"
    return "A" if cod_ciu=="110156"
    return "A" if cod_ciu=="110157"
    return "A" if cod_ciu=="110158"
    return "A" if cod_ciu=="110159"
    return "A" if cod_ciu=="110160"
    return "B" if cod_ciu=="110161"
    return "A" if cod_ciu=="110162"
    return "A" if cod_ciu=="110163"
    return "B" if cod_ciu=="110250"
    return "A" if cod_ciu=="110251"
    return "A" if cod_ciu=="110252"
    return "A" if cod_ciu=="110253"
    return "A" if cod_ciu=="110254"
    return "B" if cod_ciu=="110350"
    return "A" if cod_ciu=="110351"
    return "A" if cod_ciu=="110352"
    return "B" if cod_ciu=="110353"
    return "A" if cod_ciu=="110354"
    return "B" if cod_ciu=="110450"
    return "A" if cod_ciu=="110451"
    return "A" if cod_ciu=="110455"
    return "A" if cod_ciu=="110456"
    return "A" if cod_ciu=="110457"
    return "A" if cod_ciu=="110550"
    return "A" if cod_ciu=="110551"
    return "A" if cod_ciu=="110552"
    return "A" if cod_ciu=="110553"
    return "A" if cod_ciu=="110554"
    return "A" if cod_ciu=="110650"
    return "A" if cod_ciu=="110651"
    return "A" if cod_ciu=="110652"
    return "A" if cod_ciu=="110653"
    return "A" if cod_ciu=="110654"
    return "A" if cod_ciu=="110655"
    return "A" if cod_ciu=="110656"
    return "B" if cod_ciu=="110750"
    return "A" if cod_ciu=="110751"
    return "A" if cod_ciu=="110753"
    return "A" if cod_ciu=="110754"
    return "A" if cod_ciu=="110756"
    return "B" if cod_ciu=="110850"
    return "A" if cod_ciu=="110851"
    return "A" if cod_ciu=="110852"
    return "A" if cod_ciu=="110853"
    return "A" if cod_ciu=="110950"
    return "A" if cod_ciu=="110951"
    return "A" if cod_ciu=="110952"
    return "A" if cod_ciu=="110954"
    return "A" if cod_ciu=="110956"
    return "A" if cod_ciu=="110957"
    return "A" if cod_ciu=="110958"
    return "A" if cod_ciu=="110959"
    return "A" if cod_ciu=="111050"
    return "A" if cod_ciu=="111051"
    return "A" if cod_ciu=="111052"
    return "A" if cod_ciu=="111053"
    return "A" if cod_ciu=="111054"
    return "A" if cod_ciu=="111055"
    return "A" if cod_ciu=="111150"
    return "A" if cod_ciu=="111151"
    return "A" if cod_ciu=="111152"
    return "A" if cod_ciu=="111153"
    return "A" if cod_ciu=="111154"
    return "A" if cod_ciu=="111155"
    return "A" if cod_ciu=="111156"
    return "A" if cod_ciu=="111157"
    return "A" if cod_ciu=="111158"
    return "A" if cod_ciu=="111159"
    return "A" if cod_ciu=="111160"
    return "A" if cod_ciu=="111250"
    return "A" if cod_ciu=="111251"
    return "A" if cod_ciu=="111252"
    return "A" if cod_ciu=="111350"
    return "A" if cod_ciu=="111351"
    return "A" if cod_ciu=="111352"
    return "A" if cod_ciu=="111353"
    return "A" if cod_ciu=="111354"
    return "A" if cod_ciu=="111355"
    return "A" if cod_ciu=="111450"
    return "A" if cod_ciu=="111451"
    return "A" if cod_ciu=="111452"
    return "A" if cod_ciu=="111550"
    return "A" if cod_ciu=="111551"
    return "A" if cod_ciu=="111552"
    return "A" if cod_ciu=="111650"
    return "A" if cod_ciu=="111651"
    return "B" if cod_ciu=="120150"
    return "A" if cod_ciu=="120152"
    return "A" if cod_ciu=="120153"
    return "A" if cod_ciu=="120154"
    return "A" if cod_ciu=="120155"
    return "A" if cod_ciu=="120250"
    return "A" if cod_ciu=="120251"
    return "A" if cod_ciu=="120252"
    return "A" if cod_ciu=="120350"
    return "A" if cod_ciu=="120450"
    return "A" if cod_ciu=="120451"
    return "A" if cod_ciu=="120452"
    return "A" if cod_ciu=="120550"
    return "A" if cod_ciu=="120553"
    return "A" if cod_ciu=="120555"
    return "A" if cod_ciu=="120650"
    return "A" if cod_ciu=="120651"
    return "A" if cod_ciu=="120750"
    return "A" if cod_ciu=="120752"
    return "A" if cod_ciu=="120850"
    return "A" if cod_ciu=="120851"
    return "A" if cod_ciu=="120950"
    return "A" if cod_ciu=="121050"
    return "A" if cod_ciu=="121051"
    return "A" if cod_ciu=="121150"
    return "A" if cod_ciu=="121250"
    return "A" if cod_ciu=="121350"
    return "B" if cod_ciu=="130150"
    return "A" if cod_ciu=="130151"
    return "A" if cod_ciu=="130152"
    return "A" if cod_ciu=="130153"
    return "A" if cod_ciu=="130154"
    return "A" if cod_ciu=="130155"
    return "A" if cod_ciu=="130156"
    return "A" if cod_ciu=="130157"
    return "A" if cod_ciu=="130250"
    return "A" if cod_ciu=="130251"
    return "A" if cod_ciu=="130252"
    return "A" if cod_ciu=="130350"
    return "A" if cod_ciu=="130351"
    return "A" if cod_ciu=="130352"
    return "A" if cod_ciu=="130353"
    return "A" if cod_ciu=="130354"
    return "A" if cod_ciu=="130355"
    return "A" if cod_ciu=="130356"
    return "A" if cod_ciu=="130357"
    return "A" if cod_ciu=="130450"
    return "A" if cod_ciu=="130451"
    return "A" if cod_ciu=="130452"
    return "A" if cod_ciu=="130550"
    return "A" if cod_ciu=="130551"
    return "A" if cod_ciu=="130552"
    return "A" if cod_ciu=="130650"
    return "A" if cod_ciu=="130651"
    return "A" if cod_ciu=="130652"
    return "A" if cod_ciu=="130653"
    return "A" if cod_ciu=="130654"
    return "A" if cod_ciu=="130656"
    return "A" if cod_ciu=="130657"
    return "A" if cod_ciu=="130658"
    return "A" if cod_ciu=="130750"
    return "B" if cod_ciu=="130850"
    return "A" if cod_ciu=="130851"
    return "A" if cod_ciu=="130852"
    return "A" if cod_ciu=="130950"
    return "A" if cod_ciu=="130952"
    return "A" if cod_ciu=="131050"
    return "A" if cod_ciu=="131051"
    return "A" if cod_ciu=="131052"
    return "A" if cod_ciu=="131053"
    return "A" if cod_ciu=="131054"
    return "A" if cod_ciu=="131150"
    return "A" if cod_ciu=="131151"
    return "A" if cod_ciu=="131152"
    return "A" if cod_ciu=="131250"
    return "A" if cod_ciu=="131350"
    return "A" if cod_ciu=="131351"
    return "A" if cod_ciu=="131352"
    return "A" if cod_ciu=="131353"
    return "A" if cod_ciu=="131355"
    return "A" if cod_ciu=="131450"
    return "A" if cod_ciu=="131453"
    return "A" if cod_ciu=="131457"
    return "A" if cod_ciu=="131550"
    return "A" if cod_ciu=="131551"
    return "A" if cod_ciu=="131552"
    return "A" if cod_ciu=="131650"
    return "A" if cod_ciu=="131651"
    return "A" if cod_ciu=="131652"
    return "A" if cod_ciu=="131653"
    return "A" if cod_ciu=="131750"
    return "A" if cod_ciu=="131751"
    return "A" if cod_ciu=="131752"
    return "A" if cod_ciu=="131753"
    return "A" if cod_ciu=="131850"
    return "A" if cod_ciu=="131950"
    return "A" if cod_ciu=="131951"
    return "A" if cod_ciu=="131952"
    return "A" if cod_ciu=="132050"
    return "A" if cod_ciu=="132150"
    return "A" if cod_ciu=="132250"
    return "A" if cod_ciu=="132251"
    return "C" if cod_ciu=="140150"
    return "A" if cod_ciu=="140151"
    return "A" if cod_ciu=="140153"
    return "A" if cod_ciu=="140156"
    return "A" if cod_ciu=="140157"
    return "A" if cod_ciu=="140158"
    return "A" if cod_ciu=="140160"
    return "A" if cod_ciu=="140162"
    return "A" if cod_ciu=="140164"
    return "B" if cod_ciu=="140250"
    return "A" if cod_ciu=="140251"
    return "A" if cod_ciu=="140252"
    return "A" if cod_ciu=="140253"
    return "A" if cod_ciu=="140254"
    return "A" if cod_ciu=="140255"
    return "A" if cod_ciu=="140256"
    return "A" if cod_ciu=="140257"
    return "A" if cod_ciu=="140258"
    return "B" if cod_ciu=="140350"
    return "A" if cod_ciu=="140351"
    return "A" if cod_ciu=="140353"
    return "A" if cod_ciu=="140356"
    return "A" if cod_ciu=="140357"
    return "A" if cod_ciu=="140358"
    return "B" if cod_ciu=="140450"
    return "A" if cod_ciu=="140451"
    return "A" if cod_ciu=="140452"
    return "A" if cod_ciu=="140454"
    return "A" if cod_ciu=="140455"
    return "B" if cod_ciu=="140550"
    return "A" if cod_ciu=="140551"
    return "A" if cod_ciu=="140552"
    return "A" if cod_ciu=="140553"
    return "A" if cod_ciu=="140554"
    return "A" if cod_ciu=="140556"
    return "A" if cod_ciu=="140557"
    return "B" if cod_ciu=="140650"
    return "A" if cod_ciu=="140651"
    return "A" if cod_ciu=="140652"
    return "A" if cod_ciu=="140655"
    return "A" if cod_ciu=="140750"
    return "A" if cod_ciu=="140751"
    return "B" if cod_ciu=="140850"
    return "A" if cod_ciu=="140851"
    return "A" if cod_ciu=="140852"
    return "A" if cod_ciu=="140853"
    return "A" if cod_ciu=="140854"
    return "A" if cod_ciu=="140950"
    return "A" if cod_ciu=="140951"
    return "A" if cod_ciu=="140952"
    return "A" if cod_ciu=="140953"
    return "A" if cod_ciu=="140954"
    return "A" if cod_ciu=="141050"
    return "A" if cod_ciu=="141051"
    return "A" if cod_ciu=="141052"
    return "A" if cod_ciu=="141150"
    return "A" if cod_ciu=="141250"
    return "A" if cod_ciu=="141251"
    return "B" if cod_ciu=="150150"
    return "A" if cod_ciu=="150151"
    return "A" if cod_ciu=="150153"
    return "A" if cod_ciu=="150154"
    return "A" if cod_ciu=="150155"
    return "A" if cod_ciu=="150156"
    return "A" if cod_ciu=="150157"
    return "A" if cod_ciu=="150350"
    return "A" if cod_ciu=="150352"
    return "A" if cod_ciu=="150354"
    return "B" if cod_ciu=="150450"
    return "A" if cod_ciu=="150451"
    return "A" if cod_ciu=="150452"
    return "A" if cod_ciu=="150453"
    return "A" if cod_ciu=="150454"
    return "A" if cod_ciu=="150455"
    return "B" if cod_ciu=="150750"
    return "A" if cod_ciu=="150751"
    return "A" if cod_ciu=="150752"
    return "A" if cod_ciu=="150753"
    return "A" if cod_ciu=="150754"
    return "A" if cod_ciu=="150756"
    return "A" if cod_ciu=="150950"
    return "B" if cod_ciu=="160150"
    return "A" if cod_ciu=="160152"
    return "A" if cod_ciu=="160154"
    return "A" if cod_ciu=="160155"
    return "A" if cod_ciu=="160156"
    return "A" if cod_ciu=="160157"
    return "A" if cod_ciu=="160158"
    return "A" if cod_ciu=="160159"
    return "A" if cod_ciu=="160161"
    return "A" if cod_ciu=="160162"
    return "A" if cod_ciu=="160163"
    return "A" if cod_ciu=="160164"
    return "A" if cod_ciu=="160165"
    return "A" if cod_ciu=="160166"
    return "B" if cod_ciu=="160250"
    return "A" if cod_ciu=="160251"
    return "B" if cod_ciu=="160252"
    return "A" if cod_ciu=="160350"
    return "A" if cod_ciu=="160351"
    return "A" if cod_ciu=="160450"
    return "A" if cod_ciu=="160451"
    return "C" if cod_ciu=="170150"
    return "C" if cod_ciu=="170151"
    return "B" if cod_ciu=="170152"
    return "A" if cod_ciu=="170153"
    return "B" if cod_ciu=="170154"
    return "C" if cod_ciu=="170155"
    return "C" if cod_ciu=="170156"
    return "C" if cod_ciu=="170157"
    return "A" if cod_ciu=="170158"
    return "A" if cod_ciu=="170159"
    return "B" if cod_ciu=="170160"
    return "A" if cod_ciu=="170161"
    return "B" if cod_ciu=="170162"
    return "B" if cod_ciu=="170163"
    return "B" if cod_ciu=="170164"
    return "B" if cod_ciu=="170165"
    return "A" if cod_ciu=="170166"
    return "A" if cod_ciu=="170168"
    return "A" if cod_ciu=="170169"
    return "C" if cod_ciu=="170170"
    return "A" if cod_ciu=="170171"
    return "A" if cod_ciu=="170172"
    return "B" if cod_ciu=="170174"
    return "B" if cod_ciu=="170175"
    return "A" if cod_ciu=="170176"
    return "C" if cod_ciu=="170177"
    return "A" if cod_ciu=="170178"
    return "B" if cod_ciu=="170179"
    return "C" if cod_ciu=="170180"
    return "A" if cod_ciu=="170181"
    return "B" if cod_ciu=="170183"
    return "B" if cod_ciu=="170184"
    return "B" if cod_ciu=="170185"
    return "B" if cod_ciu=="170186"
    return "B" if cod_ciu=="170250"
    return "B" if cod_ciu=="170251"
    return "A" if cod_ciu=="170252"
    return "A" if cod_ciu=="170253"
    return "A" if cod_ciu=="170254"
    return "A" if cod_ciu=="170255"
    return "B" if cod_ciu=="170350"
    return "B" if cod_ciu=="170351"
    return "B" if cod_ciu=="170352"
    return "A" if cod_ciu=="170353"
    return "A" if cod_ciu=="170354"
    return "A" if cod_ciu=="170355"
    return "B" if cod_ciu=="170356"
    return "B" if cod_ciu=="170357"
    return "B" if cod_ciu=="170450"
    return "A" if cod_ciu=="170451"
    return "A" if cod_ciu=="170452"
    return "A" if cod_ciu=="170453"
    return "A" if cod_ciu=="170454"
    return "C" if cod_ciu=="170550"
    return "A" if cod_ciu=="170551"
    return "A" if cod_ciu=="170552"
    return "A" if cod_ciu=="170750"
    return "A" if cod_ciu=="170751"
    return "A" if cod_ciu=="170850"
    return "A" if cod_ciu=="170950"
    return "C" if cod_ciu=="180150"
    return "A" if cod_ciu=="180151"
    return "B" if cod_ciu=="180152"
    return "A" if cod_ciu=="180153"
    return "A" if cod_ciu=="180154"
    return "A" if cod_ciu=="180155"
    return "B" if cod_ciu=="180156"
    return "A" if cod_ciu=="180157"
    return "A" if cod_ciu=="180158"
    return "A" if cod_ciu=="180159"
    return "A" if cod_ciu=="180160"
    return "A" if cod_ciu=="180161"
    return "A" if cod_ciu=="180162"
    return "B" if cod_ciu=="180163"
    return "A" if cod_ciu=="180164"
    return "A" if cod_ciu=="180165"
    return "A" if cod_ciu=="180166"
    return "A" if cod_ciu=="180167"
    return "A" if cod_ciu=="180168"
    return "C" if cod_ciu=="180250"
    return "A" if cod_ciu=="180251"
    return "B" if cod_ciu=="180252"
    return "A" if cod_ciu=="180253"
    return "B" if cod_ciu=="180254"
    return "B" if cod_ciu=="180350"
    return "A" if cod_ciu=="180450"
    return "A" if cod_ciu=="180451"
    return "B" if cod_ciu=="180550"
    return "A" if cod_ciu=="180551"
    return "A" if cod_ciu=="180552"
    return "A" if cod_ciu=="180553"
    return "A" if cod_ciu=="180650"
    return "A" if cod_ciu=="180651"
    return "A" if cod_ciu=="180652"
    return "B" if cod_ciu=="180750"
    return "A" if cod_ciu=="180751"
    return "A" if cod_ciu=="180752"
    return "A" if cod_ciu=="180753"
    return "A" if cod_ciu=="180754"
    return "A" if cod_ciu=="180755"
    return "A" if cod_ciu=="180756"
    return "A" if cod_ciu=="180757"
    return "A" if cod_ciu=="180758"
    return "B" if cod_ciu=="180850"
    return "A" if cod_ciu=="180851"
    return "A" if cod_ciu=="180852"
    return "A" if cod_ciu=="180853"
    return "B" if cod_ciu=="180854"
    return "A" if cod_ciu=="180855"
    return "A" if cod_ciu=="180856"
    return "A" if cod_ciu=="180857"
    return "A" if cod_ciu=="180950"
    return "A" if cod_ciu=="180951"
    return "C" if cod_ciu=="190150"
    return "A" if cod_ciu=="190151"
    return "A" if cod_ciu=="190152"
    return "A" if cod_ciu=="190153"
    return "A" if cod_ciu=="190155"
    return "A" if cod_ciu=="190156"
    return "A" if cod_ciu=="190158"
    return "A" if cod_ciu=="190250"
    return "A" if cod_ciu=="190251"
    return "A" if cod_ciu=="190252"
    return "A" if cod_ciu=="190254"
    return "A" if cod_ciu=="190256"
    return "A" if cod_ciu=="190259"
    return "A" if cod_ciu=="190350"
    return "A" if cod_ciu=="190351"
    return "A" if cod_ciu=="190352"
    return "A" if cod_ciu=="190450"
    return "A" if cod_ciu=="190451"
    return "A" if cod_ciu=="190452"
    return "B" if cod_ciu=="190550"
    return "A" if cod_ciu=="190551"
    return "A" if cod_ciu=="190553"
    return "A" if cod_ciu=="190650"
    return "A" if cod_ciu=="190651"
    return "A" if cod_ciu=="190652"
    return "A" if cod_ciu=="190653"
    return "A" if cod_ciu=="190750"
    return "A" if cod_ciu=="190850"
    return "A" if cod_ciu=="190851"
    return "A" if cod_ciu=="190852"
    return "A" if cod_ciu=="190853"
    return "A" if cod_ciu=="190854"
    return "A" if cod_ciu=="190950"
    return "A" if cod_ciu=="190951"
    return "A" if cod_ciu=="190952"
    return "B" if cod_ciu=="200150"
    return "B" if cod_ciu=="200151"
    return "A" if cod_ciu=="200152"
    return "B" if cod_ciu=="200250"
    return "A" if cod_ciu=="200251"
    return "B" if cod_ciu=="200350"
    return "A" if cod_ciu=="200351"
    return "A" if cod_ciu=="200352"
    return "A" if cod_ciu=="210150"
    return "A" if cod_ciu=="210152"
    return "A" if cod_ciu=="210153"
    return "A" if cod_ciu=="210155"
    return "A" if cod_ciu=="210156"
    return "A" if cod_ciu=="210157"
    return "A" if cod_ciu=="210158"
    return "A" if cod_ciu=="210250"
    return "A" if cod_ciu=="210251"
    return "A" if cod_ciu=="210252"
    return "A" if cod_ciu=="210254"
    return "A" if cod_ciu=="210350"
    return "A" if cod_ciu=="210351"
    return "A" if cod_ciu=="210352"
    return "A" if cod_ciu=="210353"
    return "A" if cod_ciu=="210354"
    return "A" if cod_ciu=="210450"
    return "A" if cod_ciu=="210451"
    return "A" if cod_ciu=="210452"
    return "A" if cod_ciu=="210453"
    return "A" if cod_ciu=="210454"
    return "A" if cod_ciu=="210455"
    return "A" if cod_ciu=="210550"
    return "A" if cod_ciu=="210551"
    return "A" if cod_ciu=="210552"
    return "A" if cod_ciu=="210553"
    return "A" if cod_ciu=="210554"
    return "A" if cod_ciu=="210650"
    return "A" if cod_ciu=="210651"
    return "A" if cod_ciu=="210652"
    return "A" if cod_ciu=="210750"
    return "A" if cod_ciu=="210751"
    return "A" if cod_ciu=="210752"
    return "A" if cod_ciu=="220150"
    return "A" if cod_ciu=="220151"
    return "A" if cod_ciu=="220152"
    return "A" if cod_ciu=="220153"
    return "A" if cod_ciu=="220154"
    return "A" if cod_ciu=="220155"
    return "A" if cod_ciu=="220156"
    return "A" if cod_ciu=="220157"
    return "A" if cod_ciu=="220158"
    return "A" if cod_ciu=="220159"
    return "A" if cod_ciu=="220160"
    return "A" if cod_ciu=="220161"
    return "A" if cod_ciu=="220250"
    return "A" if cod_ciu=="220251"
    return "A" if cod_ciu=="220252"
    return "A" if cod_ciu=="220253"
    return "A" if cod_ciu=="220254"
    return "A" if cod_ciu=="220255"
    return "A" if cod_ciu=="220350"
    return "A" if cod_ciu=="220351"
    return "A" if cod_ciu=="220352"
    return "A" if cod_ciu=="220353"
    return "A" if cod_ciu=="220354"
    return "A" if cod_ciu=="220355"
    return "A" if cod_ciu=="220356"
    return "A" if cod_ciu=="220357"
    return "A" if cod_ciu=="220358"
    return "A" if cod_ciu=="220450"
    return "A" if cod_ciu=="220451"
    return "A" if cod_ciu=="220452"
    return "A" if cod_ciu=="220453"
    return "A" if cod_ciu=="220454"
    return "A" if cod_ciu=="220455"
    return "A" if cod_ciu=="230150"
    return "A" if cod_ciu=="230151"
    return "A" if cod_ciu=="230152"
    return "A" if cod_ciu=="230153"
    return "A" if cod_ciu=="230154"
    return "A" if cod_ciu=="230155"
    return "A" if cod_ciu=="230156"
    return "A" if cod_ciu=="230157"
    return "A" if cod_ciu=="240150"
    return "A" if cod_ciu=="240151"
    return "A" if cod_ciu=="240152"
    return "A" if cod_ciu=="240153"
    return "A" if cod_ciu=="240154"
    return "A" if cod_ciu=="240155"
    return "B" if cod_ciu=="240156"
    return "A" if cod_ciu=="240250"
    return "B" if cod_ciu=="240350"
    return "A" if cod_ciu=="240351"
    return "A" if cod_ciu=="240352"
    return "A" if cod_ciu=="900151"
    return "A" if cod_ciu=="900351"
    return "A" if cod_ciu=="900451"
    return "C" if cod_ciu=="020103"
  end
end
