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
    (select max(trunc(fecha)) from cred_cabecera_pagos_credito where numero_credito=ct.numero_credito
    )fecha_ultimo_pago_realizado,
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
     nvl((select tipo_sector from socios_solisoc_datos_generales where codigo_socio=th1.socio),'NV')sector,
     (SELECT substr(min(mcli_lugar_dir),3,6) from socios_direcciones where codigo_socio=th1.socio)codigo_parroquia,
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

     (case when (select sueldo_promedio_mensual from socios where codigo_socio=th1.socio)<=400 then '<= 400 USD'
   when (select sueldo_promedio_mensual from socios where codigo_socio=th1.socio) between 400 and 800 then '> 400 & <= 800 USD'
   when (select sueldo_promedio_mensual from socios where codigo_socio=th1.socio)>=800 then '> 800 USD'
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
         when TRUNC((SYSDATE-TH1.EDAD)/365.25)>60 then 'Mas de 60'
         else 'NS/NR' end)rango_edad,
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
      results.each do |row|
        row["sector"] = Oracledb.obtenerCodigoSecor2 row["codigo_parroquia"]
        row["codigo_parroquia"] = Oracledb.obtenerCodigoSecor row["codigo_parroquia"]
      end
      return results
    else
      return {}
    end

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

         (SELECT substr(min(mcli_lugar_dir),3,6) from socios_direcciones where codigo_socio=cp.codigo_socio)codigo_parroquia,
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
      (case when (select sueldo_promedio_mensual from socios where codigo_socio=cp.codigo_socio)<=400 then ' <= 400 USD'
    when (select sueldo_promedio_mensual from socios where codigo_socio=cp.codigo_socio) between 400 and 800 then ' > 400 & <= 800 USD'
    when (select sueldo_promedio_mensual from socios where codigo_socio=cp.codigo_socio)>=800 then '>= 800 USD'
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
             when TRUNC((SYSDATE-(select mcli_fecnaci from socios where codigo_socio=cp.codigo_socio))/365.25)>60 then 'Mas de 60'
             else 'NS/NR' end)rango_edad,
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
      results.each do |row|
        row["sector"] = Oracledb.obtenerCodigoSecor2 row["codigo_parroquia"]
        row["codigo_parroquia"] = Oracledb.obtenerCodigoSecor row["codigo_parroquia"]
      end
      return results
    else
      return {}
    end




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
      agencia = "Servim"
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

  def self.obtenerCodigoSecor id_parroquia
    return "Urbano" if id_parroquia=="010150"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="010151"
    return "Rural" if id_parroquia=="010152"
    return "Rural" if id_parroquia=="010153"
    return "Rural" if id_parroquia=="010154"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="010155"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="010156"
    return "Rural" if id_parroquia=="010157"
    return "Rural" if id_parroquia=="010158"
    return "Rural" if id_parroquia=="010159"
    return "Rural" if id_parroquia=="010160"
    return "Rural" if id_parroquia=="010161"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="010162"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="010163"
    return "Rural" if id_parroquia=="010164"
    return "Rural" if id_parroquia=="010165"
    return "Rural" if id_parroquia=="010166"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="010167"
    return "Rural" if id_parroquia=="010168"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="010169"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="010170"
    return "Rural" if id_parroquia=="010171"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="010250"
    return "Rural" if id_parroquia=="010251"
    return "Rural" if id_parroquia=="010252"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="010350"
    return "Rural" if id_parroquia=="010352"
    return "Rural" if id_parroquia=="010353"
    return "Rural" if id_parroquia=="010354"
    return "Rural" if id_parroquia=="010356"
    return "Rural" if id_parroquia=="010357"
    return "Rural" if id_parroquia=="010358"
    return "Rural" if id_parroquia=="010359"
    return "Rural" if id_parroquia=="010360"
    return "Rural" if id_parroquia=="010450"
    return "Rural" if id_parroquia=="010451"
    return "Rural" if id_parroquia=="010452"
    return "Rural" if id_parroquia=="010453"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="010550"
    return "Rural" if id_parroquia=="010552"
    return "Rural" if id_parroquia=="010553"
    return "Rural" if id_parroquia=="010554"
    return "Rural" if id_parroquia=="010556"
    return "Rural" if id_parroquia=="010559"
    return "Rural" if id_parroquia=="010561"
    return "Rural" if id_parroquia=="010562"
    return "Rural" if id_parroquia=="010650"
    return "Rural" if id_parroquia=="010652"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="010750"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="010751"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="010850"
    return "Rural" if id_parroquia=="010851"
    return "Rural" if id_parroquia=="010853"
    return "Rural" if id_parroquia=="010950"
    return "Rural" if id_parroquia=="010951"
    return "Rural" if id_parroquia=="010952"
    return "Rural" if id_parroquia=="010953"
    return "Rural" if id_parroquia=="010954"
    return "Rural" if id_parroquia=="010955"
    return "Rural" if id_parroquia=="010956"
    return "Rural" if id_parroquia=="011050"
    return "Rural" if id_parroquia=="011051"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="011150"
    return "Rural" if id_parroquia=="011151"
    return "Rural" if id_parroquia=="011152"
    return "Rural" if id_parroquia=="011153"
    return "Rural" if id_parroquia=="011154"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="011250"
    return "Rural" if id_parroquia=="011253"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="011350"
    return "Rural" if id_parroquia=="011351"
    return "Rural" if id_parroquia=="011352"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="011450"
    return "Rural" if id_parroquia=="011550"
    return "Rural" if id_parroquia=="011551"
    return "Rural" if id_parroquia=="020150"
    return "Rural" if id_parroquia=="020151"
    return "Rural" if id_parroquia=="020153"
    return "Rural" if id_parroquia=="020155"
    return "Rural" if id_parroquia=="020156"
    return "Rural" if id_parroquia=="020157"
    return "Rural" if id_parroquia=="020158"
    return "Rural" if id_parroquia=="020159"
    return "Rural" if id_parroquia=="020160"
    return "Rural" if id_parroquia=="020250"
    return "Rural" if id_parroquia=="020251"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="020350"
    return "Rural" if id_parroquia=="020351"
    return "Rural" if id_parroquia=="020353"
    return "Rural" if id_parroquia=="020354"
    return "Rural" if id_parroquia=="020355"
    return "Rural" if id_parroquia=="020450"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="020550"
    return "Rural" if id_parroquia=="020551"
    return "Rural" if id_parroquia=="020552"
    return "Rural" if id_parroquia=="020553"
    return "Rural" if id_parroquia=="020554"
    return "Rural" if id_parroquia=="020555"
    return "Rural" if id_parroquia=="020556"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="020650"
    return "Rural" if id_parroquia=="020750"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="030150"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="030151"
    return "Rural" if id_parroquia=="030153"
    return "Rural" if id_parroquia=="030154"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="030155"
    return "Rural" if id_parroquia=="030156"
    return "Rural" if id_parroquia=="030157"
    return "Rural" if id_parroquia=="030158"
    return "Rural" if id_parroquia=="030160"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="030250"
    return "Rural" if id_parroquia=="030251"
    return "Rural" if id_parroquia=="030252"
    return "Rural" if id_parroquia=="030253"
    return "Rural" if id_parroquia=="030254"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="030350"
    return "Rural" if id_parroquia=="030351"
    return "Rural" if id_parroquia=="030352"
    return "Rural" if id_parroquia=="030353"
    return "Rural" if id_parroquia=="030354"
    return "Rural" if id_parroquia=="030355"
    return "Rural" if id_parroquia=="030356"
    return "Rural" if id_parroquia=="030357"
    return "Rural" if id_parroquia=="030358"
    return "Rural" if id_parroquia=="030361"
    return "Rural" if id_parroquia=="030362"
    return "Rural" if id_parroquia=="030363"
    return "Rural" if id_parroquia=="030450"
    return "Rural" if id_parroquia=="030451"
    return "Rural" if id_parroquia=="030452"
    return "Rural" if id_parroquia=="030550"
    return "Rural" if id_parroquia=="030650"
    return "Rural" if id_parroquia=="030651"
    return "Rural" if id_parroquia=="030750"
    return "Urbano" if id_parroquia=="040150"
    return "Rural" if id_parroquia=="040151"
    return "Rural" if id_parroquia=="040153"
    return "Rural" if id_parroquia=="040154"
    return "Rural" if id_parroquia=="040155"
    return "Rural" if id_parroquia=="040156"
    return "Rural" if id_parroquia=="040157"
    return "Rural" if id_parroquia=="040158"
    return "Rural" if id_parroquia=="040159"
    return "Rural" if id_parroquia=="040161"
    return "Rural" if id_parroquia=="040250"
    return "Rural" if id_parroquia=="040251"
    return "Rural" if id_parroquia=="040252"
    return "Rural" if id_parroquia=="040253"
    return "Rural" if id_parroquia=="040254"
    return "Rural" if id_parroquia=="040255"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="040350"
    return "Rural" if id_parroquia=="040351"
    return "Rural" if id_parroquia=="040352"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="040353"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="040450"
    return "Rural" if id_parroquia=="040451"
    return "Rural" if id_parroquia=="040452"
    return "Rural" if id_parroquia=="040453"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="040550"
    return "Rural" if id_parroquia=="040551"
    return "Rural" if id_parroquia=="040552"
    return "Rural" if id_parroquia=="040553"
    return "Rural" if id_parroquia=="040554"
    return "Rural" if id_parroquia=="040555"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="040650"
    return "Rural" if id_parroquia=="040651"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="050150"
    return "Rural" if id_parroquia=="050151"
    return "Rural" if id_parroquia=="050152"
    return "Rural" if id_parroquia=="050153"
    return "Rural" if id_parroquia=="050154"
    return "Rural" if id_parroquia=="050156"
    return "Rural" if id_parroquia=="050157"
    return "Rural" if id_parroquia=="050158"
    return "Rural" if id_parroquia=="050159"
    return "Rural" if id_parroquia=="050161"
    return "Rural" if id_parroquia=="050162"
    return "Rural" if id_parroquia=="050250"
    return "Rural" if id_parroquia=="050251"
    return "Rural" if id_parroquia=="050252"
    return "Rural" if id_parroquia=="050350"
    return "Rural" if id_parroquia=="050351"
    return "Rural" if id_parroquia=="050352"
    return "Rural" if id_parroquia=="050353"
    return "Rural" if id_parroquia=="050450"
    return "Rural" if id_parroquia=="050451"
    return "Rural" if id_parroquia=="050453"
    return "Rural" if id_parroquia=="050455"
    return "Rural" if id_parroquia=="050456"
    return "Rural" if id_parroquia=="050457"
    return "Rural" if id_parroquia=="050458"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="050550"
    return "Rural" if id_parroquia=="050551"
    return "Rural" if id_parroquia=="050552"
    return "Rural" if id_parroquia=="050553"
    return "Rural" if id_parroquia=="050554"
    return "Rural" if id_parroquia=="050555"
    return "Rural" if id_parroquia=="050650"
    return "Rural" if id_parroquia=="050651"
    return "Rural" if id_parroquia=="050652"
    return "Rural" if id_parroquia=="050653"
    return "Rural" if id_parroquia=="050750"
    return "Rural" if id_parroquia=="050751"
    return "Rural" if id_parroquia=="050752"
    return "Rural" if id_parroquia=="050753"
    return "Rural" if id_parroquia=="050754"
    return "Urbano" if id_parroquia=="060150"
    return "Rural" if id_parroquia=="060151"
    return "Rural" if id_parroquia=="060152"
    return "Rural" if id_parroquia=="060153"
    return "Rural" if id_parroquia=="060154"
    return "Rural" if id_parroquia=="060155"
    return "Rural" if id_parroquia=="060156"
    return "Rural" if id_parroquia=="060157"
    return "Rural" if id_parroquia=="060158"
    return "Rural" if id_parroquia=="060159"
    return "Rural" if id_parroquia=="060160"
    return "Rural" if id_parroquia=="060161"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="060250"
    return "Rural" if id_parroquia=="060251"
    return "Rural" if id_parroquia=="060253"
    return "Rural" if id_parroquia=="060254"
    return "Rural" if id_parroquia=="060255"
    return "Rural" if id_parroquia=="060256"
    return "Rural" if id_parroquia=="060257"
    return "Rural" if id_parroquia=="060258"
    return "Rural" if id_parroquia=="060259"
    return "Rural" if id_parroquia=="060260"
    return "Rural" if id_parroquia=="060350"
    return "Rural" if id_parroquia=="060351"
    return "Rural" if id_parroquia=="060352"
    return "Rural" if id_parroquia=="060353"
    return "Rural" if id_parroquia=="060354"
    return "Rural" if id_parroquia=="060450"
    return "Rural" if id_parroquia=="060550"
    return "Rural" if id_parroquia=="060551"
    return "Rural" if id_parroquia=="060552"
    return "Rural" if id_parroquia=="060553"
    return "Rural" if id_parroquia=="060554"
    return "Rural" if id_parroquia=="060650"
    return "Rural" if id_parroquia=="060651"
    return "Rural" if id_parroquia=="060652"
    return "Rural" if id_parroquia=="060750"
    return "Rural" if id_parroquia=="060751"
    return "Rural" if id_parroquia=="060752"
    return "Rural" if id_parroquia=="060753"
    return "Rural" if id_parroquia=="060754"
    return "Rural" if id_parroquia=="060755"
    return "Rural" if id_parroquia=="060756"
    return "Rural" if id_parroquia=="060757"
    return "Rural" if id_parroquia=="060758"
    return "Rural" if id_parroquia=="060759"
    return "Rural" if id_parroquia=="060850"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="060950"
    return "Rural" if id_parroquia=="060951"
    return "Rural" if id_parroquia=="060952"
    return "Rural" if id_parroquia=="060953"
    return "Rural" if id_parroquia=="060954"
    return "Rural" if id_parroquia=="060955"
    return "Rural" if id_parroquia=="060956"
    return "Rural" if id_parroquia=="061050"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="070150"
    return "Rural" if id_parroquia=="070152"
    return "Rural" if id_parroquia=="070250"
    return "Rural" if id_parroquia=="070251"
    return "Rural" if id_parroquia=="070254"
    return "Rural" if id_parroquia=="070255"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="070350"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="070351"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="070352"
    return "Rural" if id_parroquia=="070353"
    return "Rural" if id_parroquia=="070354"
    return "Rural" if id_parroquia=="070355"
    return "Rural" if id_parroquia=="070450"
    return "Rural" if id_parroquia=="070451"
    return "Rural" if id_parroquia=="070550"
    return "Rural" if id_parroquia=="070650"
    return "Rural" if id_parroquia=="070651"
    return "Rural" if id_parroquia=="070652"
    return "Rural" if id_parroquia=="070653"
    return "Rural" if id_parroquia=="070654"
    return "Rural" if id_parroquia=="070750"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="070850"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="070851"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="070950"
    return "Rural" if id_parroquia=="070951"
    return "Rural" if id_parroquia=="070952"
    return "Rural" if id_parroquia=="070953"
    return "Rural" if id_parroquia=="070954"
    return "Rural" if id_parroquia=="070955"
    return "Rural" if id_parroquia=="070956"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="071050"
    return "Rural" if id_parroquia=="071051"
    return "Rural" if id_parroquia=="071052"
    return "Rural" if id_parroquia=="071053"
    return "Rural" if id_parroquia=="071054"
    return "Rural" if id_parroquia=="071055"
    return "Rural" if id_parroquia=="071056"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="071150"
    return "Rural" if id_parroquia=="071151"
    return "Rural" if id_parroquia=="071152"
    return "Rural" if id_parroquia=="071153"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="071250"
    return "Rural" if id_parroquia=="071251"
    return "Rural" if id_parroquia=="071252"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="071253"
    return "Rural" if id_parroquia=="071254"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="071255"
    return "Rural" if id_parroquia=="071256"
    return "Rural" if id_parroquia=="071257"
    return "Urbano" if id_parroquia=="071350"
    return "Rural" if id_parroquia=="071351"
    return "Rural" if id_parroquia=="071352"
    return "Rural" if id_parroquia=="071353"
    return "Rural" if id_parroquia=="071354"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="071355"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="071356"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="071357"
    return "Rural" if id_parroquia=="071358"
    return "Rural" if id_parroquia=="071359"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="071450"
    return "Rural" if id_parroquia=="071451"
    return "Rural" if id_parroquia=="071452"
    return "Rural" if id_parroquia=="071453"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="080150"
    return "Rural" if id_parroquia=="080152"
    return "Rural" if id_parroquia=="080153"
    return "Rural" if id_parroquia=="080154"
    return "Rural" if id_parroquia=="080159"
    return "Rural" if id_parroquia=="080163"
    return "Rural" if id_parroquia=="080165"
    return "Rural" if id_parroquia=="080166"
    return "Rural" if id_parroquia=="080168"
    return "Rural" if id_parroquia=="080250"
    return "Rural" if id_parroquia=="080251"
    return "Rural" if id_parroquia=="080252"
    return "Rural" if id_parroquia=="080253"
    return "Rural" if id_parroquia=="080254"
    return "Rural" if id_parroquia=="080255"
    return "Rural" if id_parroquia=="080256"
    return "Rural" if id_parroquia=="080257"
    return "Rural" if id_parroquia=="080258"
    return "Rural" if id_parroquia=="080259"
    return "Rural" if id_parroquia=="080260"
    return "Rural" if id_parroquia=="080261"
    return "Rural" if id_parroquia=="080262"
    return "Rural" if id_parroquia=="080263"
    return "Rural" if id_parroquia=="080264"
    return "Rural" if id_parroquia=="080350"
    return "Rural" if id_parroquia=="080351"
    return "Rural" if id_parroquia=="080352"
    return "Rural" if id_parroquia=="080353"
    return "Rural" if id_parroquia=="080354"
    return "Rural" if id_parroquia=="080355"
    return "Rural" if id_parroquia=="080356"
    return "Rural" if id_parroquia=="080357"
    return "Rural" if id_parroquia=="080358"
    return "Rural" if id_parroquia=="080450"
    return "Rural" if id_parroquia=="080451"
    return "Rural" if id_parroquia=="080452"
    return "Rural" if id_parroquia=="080453"
    return "Rural" if id_parroquia=="080454"
    return "Rural" if id_parroquia=="080455"
    return "Rural" if id_parroquia=="080550"
    return "Rural" if id_parroquia=="080551"
    return "Rural" if id_parroquia=="080552"
    return "Rural" if id_parroquia=="080553"
    return "Rural" if id_parroquia=="080554"
    return "Rural" if id_parroquia=="080555"
    return "Rural" if id_parroquia=="080556"
    return "Rural" if id_parroquia=="080557"
    return "Rural" if id_parroquia=="080558"
    return "Rural" if id_parroquia=="080559"
    return "Rural" if id_parroquia=="080560"
    return "Rural" if id_parroquia=="080561"
    return "Rural" if id_parroquia=="080562"
    return "Rural" if id_parroquia=="080650"
    return "Rural" if id_parroquia=="080651"
    return "Rural" if id_parroquia=="080652"
    return "Rural" if id_parroquia=="080653"
    return "Rural" if id_parroquia=="080654"
    return "Rural" if id_parroquia=="080750"
    return "Rural" if id_parroquia=="080751"
    return "Rural" if id_parroquia=="080752"
    return "Rural" if id_parroquia=="080753"
    return "Rural" if id_parroquia=="080754"
    return "Rural" if id_parroquia=="080755"
    return "Rural" if id_parroquia=="230850"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="090150"
    return "Rural" if id_parroquia=="090152"
    return "Rural" if id_parroquia=="090153"
    return "Rural" if id_parroquia=="090156"
    return "Rural" if id_parroquia=="090157"
    return "Rural" if id_parroquia=="090158"
    return "Rural" if id_parroquia=="090250"
    return "Rural" if id_parroquia=="090350"
    return "Rural" if id_parroquia=="090450"
    return "Rural" if id_parroquia=="090550"
    return "Rural" if id_parroquia=="090551"
    return "Rural" if id_parroquia=="090650"
    return "Rural" if id_parroquia=="090652"
    return "Rural" if id_parroquia=="090653"
    return "Rural" if id_parroquia=="090654"
    return "Rural" if id_parroquia=="090656"
    return "Rural" if id_parroquia=="090750"
    return "Rural" if id_parroquia=="090850"
    return "Rural" if id_parroquia=="090851"
    return "Rural" if id_parroquia=="090852"
    return "Rural" if id_parroquia=="090950"
    return "Rural" if id_parroquia=="091050"
    return "Rural" if id_parroquia=="091051"
    return "Rural" if id_parroquia=="091053"
    return "Rural" if id_parroquia=="091054"
    return "Rural" if id_parroquia=="091150"
    return "Rural" if id_parroquia=="091151"
    return "Rural" if id_parroquia=="091152"
    return "Rural" if id_parroquia=="091153"
    return "Rural" if id_parroquia=="091154"
    return "Rural" if id_parroquia=="091250"
    return "Rural" if id_parroquia=="091350"
    return "Rural" if id_parroquia=="091450"
    return "Rural" if id_parroquia=="091451"
    return "Rural" if id_parroquia=="091452"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="091650"
    return "Rural" if id_parroquia=="091651"
    return "Rural" if id_parroquia=="091850"
    return "Rural" if id_parroquia=="091950"
    return "Rural" if id_parroquia=="091951"
    return "Rural" if id_parroquia=="091952"
    return "Rural" if id_parroquia=="091953"
    return "Rural" if id_parroquia=="092050"
    return "Rural" if id_parroquia=="092053"
    return "Rural" if id_parroquia=="092055"
    return "Rural" if id_parroquia=="092056"
    return "Rural" if id_parroquia=="092150"
    return "Rural" if id_parroquia=="092250"
    return "Rural" if id_parroquia=="092251"
    return "Rural" if id_parroquia=="092350"
    return "Rural" if id_parroquia=="092450"
    return "Rural" if id_parroquia=="092550"
    return "Rural" if id_parroquia=="092750"
    return "Rural" if id_parroquia=="092850"
    return "Urbano" if id_parroquia=="100150"
    return "Rural" if id_parroquia=="100151"
    return "Rural" if id_parroquia=="100152"
    return "Rural" if id_parroquia=="100153"
    return "Rural" if id_parroquia=="100154"
    return "Rural" if id_parroquia=="100155"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="100156"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="100157"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="100250"
    return "Rural" if id_parroquia=="100251"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="100252"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="100253"
    return "Rural" if id_parroquia=="100254"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="100350"
    return "Rural" if id_parroquia=="100351"
    return "Rural" if id_parroquia=="100352"
    return "Rural" if id_parroquia=="100353"
    return "Rural" if id_parroquia=="100354"
    return "Rural" if id_parroquia=="100355"
    return "Rural" if id_parroquia=="100356"
    return "Rural" if id_parroquia=="100357"
    return "Rural" if id_parroquia=="100358"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="100450"
    return "Rural" if id_parroquia=="100451"
    return "Rural" if id_parroquia=="100452"
    return "Rural" if id_parroquia=="100453"
    return "Rural" if id_parroquia=="100454"
    return "Rural" if id_parroquia=="100455"
    return "Rural" if id_parroquia=="100456"
    return "Rural" if id_parroquia=="100457"
    return "Rural" if id_parroquia=="100458"
    return "Rural" if id_parroquia=="100459"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="100550"
    return "Rural" if id_parroquia=="100551"
    return "Rural" if id_parroquia=="100552"
    return "Rural" if id_parroquia=="100553"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="100650"
    return "Rural" if id_parroquia=="100651"
    return "Rural" if id_parroquia=="100652"
    return "Rural" if id_parroquia=="100653"
    return "Rural" if id_parroquia=="100654"
    return "Rural" if id_parroquia=="100655"
    return "Urbano" if id_parroquia=="110150"
    return "Rural" if id_parroquia=="110151"
    return "Rural" if id_parroquia=="110152"
    return "Rural" if id_parroquia=="110153"
    return "Rural" if id_parroquia=="110154"
    return "Rural" if id_parroquia=="110155"
    return "Rural" if id_parroquia=="110156"
    return "Rural" if id_parroquia=="110157"
    return "Rural" if id_parroquia=="110158"
    return "Rural" if id_parroquia=="110159"
    return "Rural" if id_parroquia=="110160"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="110161"
    return "Rural" if id_parroquia=="110162"
    return "Rural" if id_parroquia=="110163"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="110250"
    return "Rural" if id_parroquia=="110251"
    return "Rural" if id_parroquia=="110252"
    return "Rural" if id_parroquia=="110253"
    return "Rural" if id_parroquia=="110254"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="110350"
    return "Rural" if id_parroquia=="110351"
    return "Rural" if id_parroquia=="110352"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="110353"
    return "Rural" if id_parroquia=="110354"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="110450"
    return "Rural" if id_parroquia=="110451"
    return "Rural" if id_parroquia=="110455"
    return "Rural" if id_parroquia=="110456"
    return "Rural" if id_parroquia=="110457"
    return "Rural" if id_parroquia=="110550"
    return "Rural" if id_parroquia=="110551"
    return "Rural" if id_parroquia=="110552"
    return "Rural" if id_parroquia=="110553"
    return "Rural" if id_parroquia=="110554"
    return "Rural" if id_parroquia=="110650"
    return "Rural" if id_parroquia=="110651"
    return "Rural" if id_parroquia=="110652"
    return "Rural" if id_parroquia=="110653"
    return "Rural" if id_parroquia=="110654"
    return "Rural" if id_parroquia=="110655"
    return "Rural" if id_parroquia=="110656"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="110750"
    return "Rural" if id_parroquia=="110751"
    return "Rural" if id_parroquia=="110753"
    return "Rural" if id_parroquia=="110754"
    return "Rural" if id_parroquia=="110756"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="110850"
    return "Rural" if id_parroquia=="110851"
    return "Rural" if id_parroquia=="110852"
    return "Rural" if id_parroquia=="110853"
    return "Rural" if id_parroquia=="110950"
    return "Rural" if id_parroquia=="110951"
    return "Rural" if id_parroquia=="110952"
    return "Rural" if id_parroquia=="110954"
    return "Rural" if id_parroquia=="110956"
    return "Rural" if id_parroquia=="110957"
    return "Rural" if id_parroquia=="110958"
    return "Rural" if id_parroquia=="110959"
    return "Rural" if id_parroquia=="111050"
    return "Rural" if id_parroquia=="111051"
    return "Rural" if id_parroquia=="111052"
    return "Rural" if id_parroquia=="111053"
    return "Rural" if id_parroquia=="111054"
    return "Rural" if id_parroquia=="111055"
    return "Rural" if id_parroquia=="111150"
    return "Rural" if id_parroquia=="111151"
    return "Rural" if id_parroquia=="111152"
    return "Rural" if id_parroquia=="111153"
    return "Rural" if id_parroquia=="111154"
    return "Rural" if id_parroquia=="111155"
    return "Rural" if id_parroquia=="111156"
    return "Rural" if id_parroquia=="111157"
    return "Rural" if id_parroquia=="111158"
    return "Rural" if id_parroquia=="111159"
    return "Rural" if id_parroquia=="111160"
    return "Rural" if id_parroquia=="111250"
    return "Rural" if id_parroquia=="111251"
    return "Rural" if id_parroquia=="111252"
    return "Rural" if id_parroquia=="111350"
    return "Rural" if id_parroquia=="111351"
    return "Rural" if id_parroquia=="111352"
    return "Rural" if id_parroquia=="111353"
    return "Rural" if id_parroquia=="111354"
    return "Rural" if id_parroquia=="111355"
    return "Rural" if id_parroquia=="111450"
    return "Rural" if id_parroquia=="111451"
    return "Rural" if id_parroquia=="111452"
    return "Rural" if id_parroquia=="111550"
    return "Rural" if id_parroquia=="111551"
    return "Rural" if id_parroquia=="111552"
    return "Rural" if id_parroquia=="111650"
    return "Rural" if id_parroquia=="111651"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="120150"
    return "Rural" if id_parroquia=="120152"
    return "Rural" if id_parroquia=="120153"
    return "Rural" if id_parroquia=="120154"
    return "Rural" if id_parroquia=="120155"
    return "Rural" if id_parroquia=="120250"
    return "Rural" if id_parroquia=="120251"
    return "Rural" if id_parroquia=="120252"
    return "Rural" if id_parroquia=="120350"
    return "Rural" if id_parroquia=="120450"
    return "Rural" if id_parroquia=="120451"
    return "Rural" if id_parroquia=="120452"
    return "Rural" if id_parroquia=="120550"
    return "Rural" if id_parroquia=="120553"
    return "Rural" if id_parroquia=="120555"
    return "Rural" if id_parroquia=="120650"
    return "Rural" if id_parroquia=="120651"
    return "Rural" if id_parroquia=="120750"
    return "Rural" if id_parroquia=="120752"
    return "Rural" if id_parroquia=="120850"
    return "Rural" if id_parroquia=="120851"
    return "Rural" if id_parroquia=="120950"
    return "Rural" if id_parroquia=="121050"
    return "Rural" if id_parroquia=="121051"
    return "Rural" if id_parroquia=="121150"
    return "Rural" if id_parroquia=="121250"
    return "Rural" if id_parroquia=="121350"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="130150"
    return "Rural" if id_parroquia=="130151"
    return "Rural" if id_parroquia=="130152"
    return "Rural" if id_parroquia=="130153"
    return "Rural" if id_parroquia=="130154"
    return "Rural" if id_parroquia=="130155"
    return "Rural" if id_parroquia=="130156"
    return "Rural" if id_parroquia=="130157"
    return "Rural" if id_parroquia=="130250"
    return "Rural" if id_parroquia=="130251"
    return "Rural" if id_parroquia=="130252"
    return "Rural" if id_parroquia=="130350"
    return "Rural" if id_parroquia=="130351"
    return "Rural" if id_parroquia=="130352"
    return "Rural" if id_parroquia=="130353"
    return "Rural" if id_parroquia=="130354"
    return "Rural" if id_parroquia=="130355"
    return "Rural" if id_parroquia=="130356"
    return "Rural" if id_parroquia=="130357"
    return "Rural" if id_parroquia=="130450"
    return "Rural" if id_parroquia=="130451"
    return "Rural" if id_parroquia=="130452"
    return "Rural" if id_parroquia=="130550"
    return "Rural" if id_parroquia=="130551"
    return "Rural" if id_parroquia=="130552"
    return "Rural" if id_parroquia=="130650"
    return "Rural" if id_parroquia=="130651"
    return "Rural" if id_parroquia=="130652"
    return "Rural" if id_parroquia=="130653"
    return "Rural" if id_parroquia=="130654"
    return "Rural" if id_parroquia=="130656"
    return "Rural" if id_parroquia=="130657"
    return "Rural" if id_parroquia=="130658"
    return "Rural" if id_parroquia=="130750"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="130850"
    return "Rural" if id_parroquia=="130851"
    return "Rural" if id_parroquia=="130852"
    return "Rural" if id_parroquia=="130950"
    return "Rural" if id_parroquia=="130952"
    return "Rural" if id_parroquia=="131050"
    return "Rural" if id_parroquia=="131051"
    return "Rural" if id_parroquia=="131052"
    return "Rural" if id_parroquia=="131053"
    return "Rural" if id_parroquia=="131054"
    return "Rural" if id_parroquia=="131150"
    return "Rural" if id_parroquia=="131151"
    return "Rural" if id_parroquia=="131152"
    return "Rural" if id_parroquia=="131250"
    return "Rural" if id_parroquia=="131350"
    return "Rural" if id_parroquia=="131351"
    return "Rural" if id_parroquia=="131352"
    return "Rural" if id_parroquia=="131353"
    return "Rural" if id_parroquia=="131355"
    return "Rural" if id_parroquia=="131450"
    return "Rural" if id_parroquia=="131453"
    return "Rural" if id_parroquia=="131457"
    return "Rural" if id_parroquia=="131550"
    return "Rural" if id_parroquia=="131551"
    return "Rural" if id_parroquia=="131552"
    return "Rural" if id_parroquia=="131650"
    return "Rural" if id_parroquia=="131651"
    return "Rural" if id_parroquia=="131652"
    return "Rural" if id_parroquia=="131653"
    return "Rural" if id_parroquia=="131750"
    return "Rural" if id_parroquia=="131751"
    return "Rural" if id_parroquia=="131752"
    return "Rural" if id_parroquia=="131753"
    return "Rural" if id_parroquia=="131850"
    return "Rural" if id_parroquia=="131950"
    return "Rural" if id_parroquia=="131951"
    return "Rural" if id_parroquia=="131952"
    return "Rural" if id_parroquia=="132050"
    return "Rural" if id_parroquia=="132150"
    return "Rural" if id_parroquia=="132250"
    return "Rural" if id_parroquia=="132251"
    return "Urbano" if id_parroquia=="140150"
    return "Rural" if id_parroquia=="140151"
    return "Rural" if id_parroquia=="140153"
    return "Rural" if id_parroquia=="140156"
    return "Rural" if id_parroquia=="140157"
    return "Rural" if id_parroquia=="140158"
    return "Rural" if id_parroquia=="140160"
    return "Rural" if id_parroquia=="140162"
    return "Rural" if id_parroquia=="140164"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="140250"
    return "Rural" if id_parroquia=="140251"
    return "Rural" if id_parroquia=="140252"
    return "Rural" if id_parroquia=="140253"
    return "Rural" if id_parroquia=="140254"
    return "Rural" if id_parroquia=="140255"
    return "Rural" if id_parroquia=="140256"
    return "Rural" if id_parroquia=="140257"
    return "Rural" if id_parroquia=="140258"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="140350"
    return "Rural" if id_parroquia=="140351"
    return "Rural" if id_parroquia=="140353"
    return "Rural" if id_parroquia=="140356"
    return "Rural" if id_parroquia=="140357"
    return "Rural" if id_parroquia=="140358"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="140450"
    return "Rural" if id_parroquia=="140451"
    return "Rural" if id_parroquia=="140452"
    return "Rural" if id_parroquia=="140454"
    return "Rural" if id_parroquia=="140455"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="140550"
    return "Rural" if id_parroquia=="140551"
    return "Rural" if id_parroquia=="140552"
    return "Rural" if id_parroquia=="140553"
    return "Rural" if id_parroquia=="140554"
    return "Rural" if id_parroquia=="140556"
    return "Rural" if id_parroquia=="140557"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="140650"
    return "Rural" if id_parroquia=="140651"
    return "Rural" if id_parroquia=="140652"
    return "Rural" if id_parroquia=="140655"
    return "Rural" if id_parroquia=="140750"
    return "Rural" if id_parroquia=="140751"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="140850"
    return "Rural" if id_parroquia=="140851"
    return "Rural" if id_parroquia=="140852"
    return "Rural" if id_parroquia=="140853"
    return "Rural" if id_parroquia=="140854"
    return "Rural" if id_parroquia=="140950"
    return "Rural" if id_parroquia=="140951"
    return "Rural" if id_parroquia=="140952"
    return "Rural" if id_parroquia=="140953"
    return "Rural" if id_parroquia=="140954"
    return "Rural" if id_parroquia=="141050"
    return "Rural" if id_parroquia=="141051"
    return "Rural" if id_parroquia=="141052"
    return "Rural" if id_parroquia=="141150"
    return "Rural" if id_parroquia=="141250"
    return "Rural" if id_parroquia=="141251"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="150150"
    return "Rural" if id_parroquia=="150151"
    return "Rural" if id_parroquia=="150153"
    return "Rural" if id_parroquia=="150154"
    return "Rural" if id_parroquia=="150155"
    return "Rural" if id_parroquia=="150156"
    return "Rural" if id_parroquia=="150157"
    return "Rural" if id_parroquia=="150350"
    return "Rural" if id_parroquia=="150352"
    return "Rural" if id_parroquia=="150354"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="150450"
    return "Rural" if id_parroquia=="150451"
    return "Rural" if id_parroquia=="150452"
    return "Rural" if id_parroquia=="150453"
    return "Rural" if id_parroquia=="150454"
    return "Rural" if id_parroquia=="150455"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="150750"
    return "Rural" if id_parroquia=="150751"
    return "Rural" if id_parroquia=="150752"
    return "Rural" if id_parroquia=="150753"
    return "Rural" if id_parroquia=="150754"
    return "Rural" if id_parroquia=="150756"
    return "Rural" if id_parroquia=="150950"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="160150"
    return "Rural" if id_parroquia=="160152"
    return "Rural" if id_parroquia=="160154"
    return "Rural" if id_parroquia=="160155"
    return "Rural" if id_parroquia=="160156"
    return "Rural" if id_parroquia=="160157"
    return "Rural" if id_parroquia=="160158"
    return "Rural" if id_parroquia=="160159"
    return "Rural" if id_parroquia=="160161"
    return "Rural" if id_parroquia=="160162"
    return "Rural" if id_parroquia=="160163"
    return "Rural" if id_parroquia=="160164"
    return "Rural" if id_parroquia=="160165"
    return "Rural" if id_parroquia=="160166"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="160250"
    return "Rural" if id_parroquia=="160251"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="160252"
    return "Rural" if id_parroquia=="160350"
    return "Rural" if id_parroquia=="160351"
    return "Rural" if id_parroquia=="160450"
    return "Rural" if id_parroquia=="160451"
    return "Urbano" if id_parroquia=="170150"
    return "Urbano" if id_parroquia=="170151"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170152"
    return "Rural" if id_parroquia=="170153"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170154"
    return "Urbano" if id_parroquia=="170155"
    return "Urbano" if id_parroquia=="170156"
    return "Urbano" if id_parroquia=="170157"
    return "Rural" if id_parroquia=="170158"
    return "Rural" if id_parroquia=="170159"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170160"
    return "Rural" if id_parroquia=="170161"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170162"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170163"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170164"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170165"
    return "Rural" if id_parroquia=="170166"
    return "Rural" if id_parroquia=="170168"
    return "Rural" if id_parroquia=="170169"
    return "Urbano" if id_parroquia=="170170"
    return "Rural" if id_parroquia=="170171"
    return "Rural" if id_parroquia=="170172"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170174"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170175"
    return "Rural" if id_parroquia=="170176"
    return "Urbano" if id_parroquia=="170177"
    return "Rural" if id_parroquia=="170178"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170179"
    return "Urbano" if id_parroquia=="170180"
    return "Rural" if id_parroquia=="170181"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170183"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170184"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170185"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170186"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170250"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170251"
    return "Rural" if id_parroquia=="170252"
    return "Rural" if id_parroquia=="170253"
    return "Rural" if id_parroquia=="170254"
    return "Rural" if id_parroquia=="170255"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170350"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170351"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170352"
    return "Rural" if id_parroquia=="170353"
    return "Rural" if id_parroquia=="170354"
    return "Rural" if id_parroquia=="170355"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170356"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170357"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="170450"
    return "Rural" if id_parroquia=="170451"
    return "Rural" if id_parroquia=="170452"
    return "Rural" if id_parroquia=="170453"
    return "Rural" if id_parroquia=="170454"
    return "Urbano" if id_parroquia=="170550"
    return "Rural" if id_parroquia=="170551"
    return "Rural" if id_parroquia=="170552"
    return "Rural" if id_parroquia=="170750"
    return "Rural" if id_parroquia=="170751"
    return "Rural" if id_parroquia=="170850"
    return "Rural" if id_parroquia=="170950"
    return "Urbano" if id_parroquia=="180150"
    return "Rural" if id_parroquia=="180151"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="180152"
    return "Rural" if id_parroquia=="180153"
    return "Rural" if id_parroquia=="180154"
    return "Rural" if id_parroquia=="180155"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="180156"
    return "Rural" if id_parroquia=="180157"
    return "Rural" if id_parroquia=="180158"
    return "Rural" if id_parroquia=="180159"
    return "Rural" if id_parroquia=="180160"
    return "Rural" if id_parroquia=="180161"
    return "Rural" if id_parroquia=="180162"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="180163"
    return "Rural" if id_parroquia=="180164"
    return "Rural" if id_parroquia=="180165"
    return "Rural" if id_parroquia=="180166"
    return "Rural" if id_parroquia=="180167"
    return "Rural" if id_parroquia=="180168"
    return "Urbano" if id_parroquia=="180250"
    return "Rural" if id_parroquia=="180251"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="180252"
    return "Rural" if id_parroquia=="180253"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="180254"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="180350"
    return "Rural" if id_parroquia=="180450"
    return "Rural" if id_parroquia=="180451"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="180550"
    return "Rural" if id_parroquia=="180551"
    return "Rural" if id_parroquia=="180552"
    return "Rural" if id_parroquia=="180553"
    return "Rural" if id_parroquia=="180650"
    return "Rural" if id_parroquia=="180651"
    return "Rural" if id_parroquia=="180652"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="180750"
    return "Rural" if id_parroquia=="180751"
    return "Rural" if id_parroquia=="180752"
    return "Rural" if id_parroquia=="180753"
    return "Rural" if id_parroquia=="180754"
    return "Rural" if id_parroquia=="180755"
    return "Rural" if id_parroquia=="180756"
    return "Rural" if id_parroquia=="180757"
    return "Rural" if id_parroquia=="180758"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="180850"
    return "Rural" if id_parroquia=="180851"
    return "Rural" if id_parroquia=="180852"
    return "Rural" if id_parroquia=="180853"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="180854"
    return "Rural" if id_parroquia=="180855"
    return "Rural" if id_parroquia=="180856"
    return "Rural" if id_parroquia=="180857"
    return "Rural" if id_parroquia=="180950"
    return "Rural" if id_parroquia=="180951"
    return "Urbano" if id_parroquia=="190150"
    return "Rural" if id_parroquia=="190151"
    return "Rural" if id_parroquia=="190152"
    return "Rural" if id_parroquia=="190153"
    return "Rural" if id_parroquia=="190155"
    return "Rural" if id_parroquia=="190156"
    return "Rural" if id_parroquia=="190158"
    return "Rural" if id_parroquia=="190250"
    return "Rural" if id_parroquia=="190251"
    return "Rural" if id_parroquia=="190252"
    return "Rural" if id_parroquia=="190254"
    return "Rural" if id_parroquia=="190256"
    return "Rural" if id_parroquia=="190259"
    return "Rural" if id_parroquia=="190350"
    return "Rural" if id_parroquia=="190351"
    return "Rural" if id_parroquia=="190352"
    return "Rural" if id_parroquia=="190450"
    return "Rural" if id_parroquia=="190451"
    return "Rural" if id_parroquia=="190452"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="190550"
    return "Rural" if id_parroquia=="190551"
    return "Rural" if id_parroquia=="190553"
    return "Rural" if id_parroquia=="190650"
    return "Rural" if id_parroquia=="190651"
    return "Rural" if id_parroquia=="190652"
    return "Rural" if id_parroquia=="190653"
    return "Rural" if id_parroquia=="190750"
    return "Rural" if id_parroquia=="190850"
    return "Rural" if id_parroquia=="190851"
    return "Rural" if id_parroquia=="190852"
    return "Rural" if id_parroquia=="190853"
    return "Rural" if id_parroquia=="190854"
    return "Rural" if id_parroquia=="190950"
    return "Rural" if id_parroquia=="190951"
    return "Rural" if id_parroquia=="190952"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="200150"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="200151"
    return "Rural" if id_parroquia=="200152"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="200250"
    return "Rural" if id_parroquia=="200251"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="200350"
    return "Rural" if id_parroquia=="200351"
    return "Rural" if id_parroquia=="200352"
    return "Rural" if id_parroquia=="210150"
    return "Rural" if id_parroquia=="210152"
    return "Rural" if id_parroquia=="210153"
    return "Rural" if id_parroquia=="210155"
    return "Rural" if id_parroquia=="210156"
    return "Rural" if id_parroquia=="210157"
    return "Rural" if id_parroquia=="210158"
    return "Rural" if id_parroquia=="210250"
    return "Rural" if id_parroquia=="210251"
    return "Rural" if id_parroquia=="210252"
    return "Rural" if id_parroquia=="210254"
    return "Rural" if id_parroquia=="210350"
    return "Rural" if id_parroquia=="210351"
    return "Rural" if id_parroquia=="210352"
    return "Rural" if id_parroquia=="210353"
    return "Rural" if id_parroquia=="210354"
    return "Rural" if id_parroquia=="210450"
    return "Rural" if id_parroquia=="210451"
    return "Rural" if id_parroquia=="210452"
    return "Rural" if id_parroquia=="210453"
    return "Rural" if id_parroquia=="210454"
    return "Rural" if id_parroquia=="210455"
    return "Rural" if id_parroquia=="210550"
    return "Rural" if id_parroquia=="210551"
    return "Rural" if id_parroquia=="210552"
    return "Rural" if id_parroquia=="210553"
    return "Rural" if id_parroquia=="210554"
    return "Rural" if id_parroquia=="210650"
    return "Rural" if id_parroquia=="210651"
    return "Rural" if id_parroquia=="210652"
    return "Rural" if id_parroquia=="210750"
    return "Rural" if id_parroquia=="210751"
    return "Rural" if id_parroquia=="210752"
    return "Rural" if id_parroquia=="220150"
    return "Rural" if id_parroquia=="220151"
    return "Rural" if id_parroquia=="220152"
    return "Rural" if id_parroquia=="220153"
    return "Rural" if id_parroquia=="220154"
    return "Rural" if id_parroquia=="220155"
    return "Rural" if id_parroquia=="220156"
    return "Rural" if id_parroquia=="220157"
    return "Rural" if id_parroquia=="220158"
    return "Rural" if id_parroquia=="220159"
    return "Rural" if id_parroquia=="220160"
    return "Rural" if id_parroquia=="220161"
    return "Rural" if id_parroquia=="220250"
    return "Rural" if id_parroquia=="220251"
    return "Rural" if id_parroquia=="220252"
    return "Rural" if id_parroquia=="220253"
    return "Rural" if id_parroquia=="220254"
    return "Rural" if id_parroquia=="220255"
    return "Rural" if id_parroquia=="220350"
    return "Rural" if id_parroquia=="220351"
    return "Rural" if id_parroquia=="220352"
    return "Rural" if id_parroquia=="220353"
    return "Rural" if id_parroquia=="220354"
    return "Rural" if id_parroquia=="220355"
    return "Rural" if id_parroquia=="220356"
    return "Rural" if id_parroquia=="220357"
    return "Rural" if id_parroquia=="220358"
    return "Rural" if id_parroquia=="220450"
    return "Rural" if id_parroquia=="220451"
    return "Rural" if id_parroquia=="220452"
    return "Rural" if id_parroquia=="220453"
    return "Rural" if id_parroquia=="220454"
    return "Rural" if id_parroquia=="220455"
    return "Rural" if id_parroquia=="230150"
    return "Rural" if id_parroquia=="230151"
    return "Rural" if id_parroquia=="230152"
    return "Rural" if id_parroquia=="230153"
    return "Rural" if id_parroquia=="230154"
    return "Rural" if id_parroquia=="230155"
    return "Rural" if id_parroquia=="230156"
    return "Rural" if id_parroquia=="230157"
    return "Rural" if id_parroquia=="240150"
    return "Rural" if id_parroquia=="240151"
    return "Rural" if id_parroquia=="240152"
    return "Rural" if id_parroquia=="240153"
    return "Rural" if id_parroquia=="240154"
    return "Rural" if id_parroquia=="240155"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="240156"
    return "Rural" if id_parroquia=="240250"
    return "Peri-Urbano/Urbano-Marginal" if id_parroquia=="240350"
    return "Rural" if id_parroquia=="240351"
    return "Rural" if id_parroquia=="240352"
    return "Rural" if id_parroquia=="900151"
    return "Rural" if id_parroquia=="900351"
    return "Rural" if id_parroquia=="900451"
    return "Urbano" if id_parroquia=="010101"
    return "Urbano" if id_parroquia=="010102"
    return "Urbano" if id_parroquia=="010103"
    return "Urbano" if id_parroquia=="010104"
    return "Urbano" if id_parroquia=="010105"
    return "Urbano" if id_parroquia=="010106"
    return "Urbano" if id_parroquia=="010107"
    return "Urbano" if id_parroquia=="010108"
    return "Urbano" if id_parroquia=="010109"
    return "Urbano" if id_parroquia=="010110"
    return "Urbano" if id_parroquia=="010111"
    return "Urbano" if id_parroquia=="010112"
    return "Urbano" if id_parroquia=="010113"
    return "Urbano" if id_parroquia=="010114"
    return "Urbano" if id_parroquia=="010115"
    return "Urbano" if id_parroquia=="020101"
    return "Urbano" if id_parroquia=="020102"
    return "Urbano" if id_parroquia=="020103"
    return "Urbano" if id_parroquia=="020701"
    return "Urbano" if id_parroquia=="020702"
    return "Urbano" if id_parroquia=="030101"
    return "Urbano" if id_parroquia=="030102"
    return "Urbano" if id_parroquia=="030103"
    return "Urbano" if id_parroquia=="030104"
    return "Urbano" if id_parroquia=="040101"
    return "Urbano" if id_parroquia=="040102"
    return "Urbano" if id_parroquia=="040301"
    return "Urbano" if id_parroquia=="040302"
    return "Urbano" if id_parroquia=="040501"
    return "Urbano" if id_parroquia=="040502"
    return "Urbano" if id_parroquia=="050101"
    return "Urbano" if id_parroquia=="050102"
    return "Urbano" if id_parroquia=="050103"
    return "Urbano" if id_parroquia=="050104"
    return "Urbano" if id_parroquia=="050105"
    return "Urbano" if id_parroquia=="050201"
    return "Urbano" if id_parroquia=="050202"
    return "Urbano" if id_parroquia=="050203"
    return "Urbano" if id_parroquia=="060101"
    return "Urbano" if id_parroquia=="060102"
    return "Urbano" if id_parroquia=="060103"
    return "Urbano" if id_parroquia=="060104"
    return "Urbano" if id_parroquia=="060105"
    return "Urbano" if id_parroquia=="060301"
    return "Urbano" if id_parroquia=="060302"
    return "Urbano" if id_parroquia=="060701"
    return "Urbano" if id_parroquia=="060702"
    return "Urbano" if id_parroquia=="070101"
    return "Urbano" if id_parroquia=="070102"
    return "Urbano" if id_parroquia=="070103"
    return "Urbano" if id_parroquia=="070104"
    return "Urbano" if id_parroquia=="070105"
    return "Urbano" if id_parroquia=="070701"
    return "Urbano" if id_parroquia=="070702"
    return "Urbano" if id_parroquia=="070703"
    return "Urbano" if id_parroquia=="070704"
    return "Urbano" if id_parroquia=="070705"
    return "Urbano" if id_parroquia=="070901"
    return "Urbano" if id_parroquia=="070902"
    return "Urbano" if id_parroquia=="070903"
    return "Urbano" if id_parroquia=="070904"
    return "Urbano" if id_parroquia=="071001"
    return "Urbano" if id_parroquia=="071002"
    return "Urbano" if id_parroquia=="071003"
    return "Urbano" if id_parroquia=="071201"
    return "Urbano" if id_parroquia=="071202"
    return "Urbano" if id_parroquia=="071203"
    return "Urbano" if id_parroquia=="071204"
    return "Urbano" if id_parroquia=="071205"
    return "Urbano" if id_parroquia=="071401"
    return "Urbano" if id_parroquia=="071402"
    return "Urbano" if id_parroquia=="071403"
    return "Urbano" if id_parroquia=="080101"
    return "Urbano" if id_parroquia=="080102"
    return "Urbano" if id_parroquia=="080103"
    return "Urbano" if id_parroquia=="080104"
    return "Urbano" if id_parroquia=="080105"
    return "Urbano" if id_parroquia=="090101"
    return "Urbano" if id_parroquia=="090102"
    return "Urbano" if id_parroquia=="090103"
    return "Urbano" if id_parroquia=="090104"
    return "Urbano" if id_parroquia=="090105"
    return "Urbano" if id_parroquia=="090106"
    return "Urbano" if id_parroquia=="090107"
    return "Urbano" if id_parroquia=="090108"
    return "Urbano" if id_parroquia=="090109"
    return "Urbano" if id_parroquia=="090110"
    return "Urbano" if id_parroquia=="090111"
    return "Urbano" if id_parroquia=="090112"
    return "Urbano" if id_parroquia=="090113"
    return "Urbano" if id_parroquia=="090114"
    return "Urbano" if id_parroquia=="090115"
    return "Urbano" if id_parroquia=="090601"
    return "Urbano" if id_parroquia=="090602"
    return "Urbano" if id_parroquia=="090603"
    return "Urbano" if id_parroquia=="090604"
    return "Urbano" if id_parroquia=="090605"
    return "Urbano" if id_parroquia=="090606"
    return "Urbano" if id_parroquia=="090607"
    return "Urbano" if id_parroquia=="090608"
    return "Urbano" if id_parroquia=="090701"
    return "Urbano" if id_parroquia=="090702"
    return "Urbano" if id_parroquia=="090703"
    return "Urbano" if id_parroquia=="091001"
    return "Urbano" if id_parroquia=="091002"
    return "Urbano" if id_parroquia=="091003"
    return "Urbano" if id_parroquia=="091004"
    return "Urbano" if id_parroquia=="091005"
    return "Urbano" if id_parroquia=="091006"
    return "Urbano" if id_parroquia=="091007"
    return "Urbano" if id_parroquia=="091008"
    return "Urbano" if id_parroquia=="091009"
    return "Urbano" if id_parroquia=="091601"
    return "Urbano" if id_parroquia=="091602"
    return "Urbano" if id_parroquia=="091901"
    return "Urbano" if id_parroquia=="091902"
    return "Urbano" if id_parroquia=="091903"
    return "Urbano" if id_parroquia=="091904"
    return "Urbano" if id_parroquia=="091905"
    return "Urbano" if id_parroquia=="100101"
    return "Urbano" if id_parroquia=="100102"
    return "Urbano" if id_parroquia=="100103"
    return "Urbano" if id_parroquia=="100104"
    return "Urbano" if id_parroquia=="100105"
    return "Urbano" if id_parroquia=="100201"
    return "Urbano" if id_parroquia=="100202"
    return "Urbano" if id_parroquia=="100301"
    return "Urbano" if id_parroquia=="100302"
    return "Urbano" if id_parroquia=="100401"
    return "Urbano" if id_parroquia=="100402"
    return "Urbano" if id_parroquia=="110101"
    return "Urbano" if id_parroquia=="110102"
    return "Urbano" if id_parroquia=="110103"
    return "Urbano" if id_parroquia=="110104"
    return "Urbano" if id_parroquia=="110105"
    return "Urbano" if id_parroquia=="110106"
    return "Urbano" if id_parroquia=="110201"
    return "Urbano" if id_parroquia=="110202"
    return "Urbano" if id_parroquia=="110203"
    return "Urbano" if id_parroquia=="110301"
    return "Urbano" if id_parroquia=="110302"
    return "Urbano" if id_parroquia=="110801"
    return "Urbano" if id_parroquia=="110802"
    return "Urbano" if id_parroquia=="110901"
    return "Urbano" if id_parroquia=="110902"
    return "Urbano" if id_parroquia=="120101"
    return "Urbano" if id_parroquia=="120102"
    return "Urbano" if id_parroquia=="120103"
    return "Urbano" if id_parroquia=="120104"
    return "Urbano" if id_parroquia=="120501"
    return "Urbano" if id_parroquia=="120502"
    return "Urbano" if id_parroquia=="120504"
    return "Urbano" if id_parroquia=="120505"
    return "Urbano" if id_parroquia=="120506"
    return "Urbano" if id_parroquia=="120507"
    return "Urbano" if id_parroquia=="120508"
    return "Urbano" if id_parroquia=="120509"
    return "Urbano" if id_parroquia=="120510"
    return "Urbano" if id_parroquia=="120701"
    return "Urbano" if id_parroquia=="120702"
    return "Urbano" if id_parroquia=="120801"
    return "Urbano" if id_parroquia=="120802"
    return "Urbano" if id_parroquia=="120803"
    return "Urbano" if id_parroquia=="121001"
    return "Urbano" if id_parroquia=="121002"
    return "Urbano" if id_parroquia=="121003"
    return "Urbano" if id_parroquia=="121101"
    return "Urbano" if id_parroquia=="121102"
    return "Urbano" if id_parroquia=="121103"
    return "Urbano" if id_parroquia=="130101"
    return "Urbano" if id_parroquia=="130102"
    return "Urbano" if id_parroquia=="130103"
    return "Urbano" if id_parroquia=="130104"
    return "Urbano" if id_parroquia=="130105"
    return "Urbano" if id_parroquia=="130106"
    return "Urbano" if id_parroquia=="130107"
    return "Urbano" if id_parroquia=="130108"
    return "Urbano" if id_parroquia=="130109"
    return "Urbano" if id_parroquia=="130301"
    return "Urbano" if id_parroquia=="130302"
    return "Urbano" if id_parroquia=="130401"
    return "Urbano" if id_parroquia=="130402"
    return "Urbano" if id_parroquia=="130601"
    return "Urbano" if id_parroquia=="130602"
    return "Urbano" if id_parroquia=="130603"
    return "Urbano" if id_parroquia=="130801"
    return "Urbano" if id_parroquia=="130802"
    return "Urbano" if id_parroquia=="130803"
    return "Urbano" if id_parroquia=="130804"
    return "Urbano" if id_parroquia=="130805"
    return "Urbano" if id_parroquia=="130901"
    return "Urbano" if id_parroquia=="130902"
    return "Urbano" if id_parroquia=="130903"
    return "Urbano" if id_parroquia=="130904"
    return "Urbano" if id_parroquia=="130905"
    return "Urbano" if id_parroquia=="131301"
    return "Urbano" if id_parroquia=="131302"
    return "Urbano" if id_parroquia=="131401"
    return "Urbano" if id_parroquia=="131402"
    return "Urbano" if id_parroquia=="140201"
    return "Urbano" if id_parroquia=="140202"
    return "Urbano" if id_parroquia=="170101"
    return "Urbano" if id_parroquia=="170102"
    return "Urbano" if id_parroquia=="170103"
    return "Urbano" if id_parroquia=="170104"
    return "Urbano" if id_parroquia=="170105"
    return "Urbano" if id_parroquia=="170106"
    return "Urbano" if id_parroquia=="170107"
    return "Urbano" if id_parroquia=="170108"
    return "Urbano" if id_parroquia=="170109"
    return "Urbano" if id_parroquia=="170110"
    return "Urbano" if id_parroquia=="170111"
    return "Urbano" if id_parroquia=="170112"
    return "Urbano" if id_parroquia=="170113"
    return "Urbano" if id_parroquia=="170114"
    return "Urbano" if id_parroquia=="170115"
    return "Urbano" if id_parroquia=="170116"
    return "Urbano" if id_parroquia=="170117"
    return "Urbano" if id_parroquia=="170118"
    return "Urbano" if id_parroquia=="170119"
    return "Urbano" if id_parroquia=="170120"
    return "Urbano" if id_parroquia=="170121"
    return "Urbano" if id_parroquia=="170122"
    return "Urbano" if id_parroquia=="170123"
    return "Urbano" if id_parroquia=="170124"
    return "Urbano" if id_parroquia=="170125"
    return "Urbano" if id_parroquia=="170126"
    return "Urbano" if id_parroquia=="170127"
    return "Urbano" if id_parroquia=="170128"
    return "Urbano" if id_parroquia=="170129"
    return "Urbano" if id_parroquia=="170130"
    return "Urbano" if id_parroquia=="170131"
    return "Urbano" if id_parroquia=="170132"
    return "Urbano" if id_parroquia=="170202"
    return "Urbano" if id_parroquia=="170203"
    return "Urbano" if id_parroquia=="170501"
    return "Urbano" if id_parroquia=="170502"
    return "Urbano" if id_parroquia=="170503"
    return "Urbano" if id_parroquia=="180101"
    return "Urbano" if id_parroquia=="180102"
    return "Urbano" if id_parroquia=="180103"
    return "Urbano" if id_parroquia=="180104"
    return "Urbano" if id_parroquia=="180105"
    return "Urbano" if id_parroquia=="180106"
    return "Urbano" if id_parroquia=="180107"
    return "Urbano" if id_parroquia=="180108"
    return "Urbano" if id_parroquia=="180109"
    return "Urbano" if id_parroquia=="180701"
    return "Urbano" if id_parroquia=="180702"
    return "Urbano" if id_parroquia=="180801"
    return "Urbano" if id_parroquia=="180802"
    return "Urbano" if id_parroquia=="190101"
    return "Urbano" if id_parroquia=="190102"
    return "Urbano" if id_parroquia=="230101"
    return "Urbano" if id_parroquia=="230102"
    return "Urbano" if id_parroquia=="230103"
    return "Urbano" if id_parroquia=="230104"
    return "Urbano" if id_parroquia=="230105"
    return "Urbano" if id_parroquia=="230106"
    return "Urbano" if id_parroquia=="230107"
    return "Urbano" if id_parroquia=="240101"
    return "Urbano" if id_parroquia=="240102"
    return "Urbano" if id_parroquia=="240301"
    return "Urbano" if id_parroquia=="240302"
    return "Urbano" if id_parroquia=="240303"
    return "Urbano" if id_parroquia=="240304"
  end

  def self.obtenerCodigoSecor2 id_parroquia
    return "Rural" if id_parroquia=="010150"
    return "Rural" if id_parroquia=="010151"
    return "Rural" if id_parroquia=="010152"
    return "Rural" if id_parroquia=="010153"
    return "Rural" if id_parroquia=="010154"
    return "Rural" if id_parroquia=="010155"
    return "Rural" if id_parroquia=="010156"
    return "Rural" if id_parroquia=="010157"
    return "Rural" if id_parroquia=="010158"
    return "Rural" if id_parroquia=="010159"
    return "Rural" if id_parroquia=="010160"
    return "Rural" if id_parroquia=="010161"
    return "Rural" if id_parroquia=="010162"
    return "Rural" if id_parroquia=="010163"
    return "Rural" if id_parroquia=="010164"
    return "Rural" if id_parroquia=="010165"
    return "Rural" if id_parroquia=="010166"
    return "Rural" if id_parroquia=="010167"
    return "Rural" if id_parroquia=="010168"
    return "Rural" if id_parroquia=="010169"
    return "Rural" if id_parroquia=="010170"
    return "Rural" if id_parroquia=="010171"
    return "Rural" if id_parroquia=="010250"
    return "Rural" if id_parroquia=="010251"
    return "Rural" if id_parroquia=="010252"
    return "Rural" if id_parroquia=="010350"
    return "Rural" if id_parroquia=="010352"
    return "Rural" if id_parroquia=="010353"
    return "Rural" if id_parroquia=="010354"
    return "Rural" if id_parroquia=="010356"
    return "Rural" if id_parroquia=="010357"
    return "Rural" if id_parroquia=="010358"
    return "Rural" if id_parroquia=="010359"
    return "Rural" if id_parroquia=="010360"
    return "Rural" if id_parroquia=="010450"
    return "Rural" if id_parroquia=="010451"
    return "Rural" if id_parroquia=="010452"
    return "Rural" if id_parroquia=="010453"
    return "Rural" if id_parroquia=="010550"
    return "Rural" if id_parroquia=="010552"
    return "Rural" if id_parroquia=="010553"
    return "Rural" if id_parroquia=="010554"
    return "Rural" if id_parroquia=="010556"
    return "Rural" if id_parroquia=="010559"
    return "Rural" if id_parroquia=="010561"
    return "Rural" if id_parroquia=="010562"
    return "Rural" if id_parroquia=="010650"
    return "Rural" if id_parroquia=="010652"
    return "Rural" if id_parroquia=="010750"
    return "Rural" if id_parroquia=="010751"
    return "Rural" if id_parroquia=="010850"
    return "Rural" if id_parroquia=="010851"
    return "Rural" if id_parroquia=="010852"
    return "Rural" if id_parroquia=="010853"
    return "Rural" if id_parroquia=="010854"
    return "Rural" if id_parroquia=="010950"
    return "Rural" if id_parroquia=="010951"
    return "Rural" if id_parroquia=="010952"
    return "Rural" if id_parroquia=="010953"
    return "Rural" if id_parroquia=="010954"
    return "Rural" if id_parroquia=="010955"
    return "Rural" if id_parroquia=="010956"
    return "Rural" if id_parroquia=="011050"
    return "Rural" if id_parroquia=="011051"
    return "Rural" if id_parroquia=="011150"
    return "Rural" if id_parroquia=="011151"
    return "Rural" if id_parroquia=="011152"
    return "Rural" if id_parroquia=="011153"
    return "Rural" if id_parroquia=="011154"
    return "Rural" if id_parroquia=="011250"
    return "Rural" if id_parroquia=="011253"
    return "Rural" if id_parroquia=="011350"
    return "Rural" if id_parroquia=="011351"
    return "Rural" if id_parroquia=="011352"
    return "Rural" if id_parroquia=="011450"
    return "Rural" if id_parroquia=="011550"
    return "Rural" if id_parroquia=="020150"
    return "Rural" if id_parroquia=="020151"
    return "Rural" if id_parroquia=="020153"
    return "Rural" if id_parroquia=="020155"
    return "Rural" if id_parroquia=="020156"
    return "Rural" if id_parroquia=="020157"
    return "Rural" if id_parroquia=="020158"
    return "Rural" if id_parroquia=="020159"
    return "Rural" if id_parroquia=="020160"
    return "Rural" if id_parroquia=="020250"
    return "Rural" if id_parroquia=="020251"
    return "Rural" if id_parroquia=="020350"
    return "Rural" if id_parroquia=="020351"
    return "Rural" if id_parroquia=="020353"
    return "Rural" if id_parroquia=="020354"
    return "Rural" if id_parroquia=="020355"
    return "Rural" if id_parroquia=="020450"
    return "Rural" if id_parroquia=="020550"
    return "Rural" if id_parroquia=="020551"
    return "Rural" if id_parroquia=="020552"
    return "Rural" if id_parroquia=="020553"
    return "Rural" if id_parroquia=="020554"
    return "Rural" if id_parroquia=="020555"
    return "Rural" if id_parroquia=="020556"
    return "Rural" if id_parroquia=="020650"
    return "Rural" if id_parroquia=="020750"
    return "Rural" if id_parroquia=="030150"
    return "Rural" if id_parroquia=="030151"
    return "Rural" if id_parroquia=="030153"
    return "Rural" if id_parroquia=="030154"
    return "Rural" if id_parroquia=="030155"
    return "Rural" if id_parroquia=="030156"
    return "Rural" if id_parroquia=="030157"
    return "Rural" if id_parroquia=="030158"
    return "Rural" if id_parroquia=="030160"
    return "Rural" if id_parroquia=="030250"
    return "Rural" if id_parroquia=="030251"
    return "Rural" if id_parroquia=="030252"
    return "Rural" if id_parroquia=="030253"
    return "Rural" if id_parroquia=="030254"
    return "Rural" if id_parroquia=="030350"
    return "Rural" if id_parroquia=="030351"
    return "Rural" if id_parroquia=="030352"
    return "Rural" if id_parroquia=="030353"
    return "Rural" if id_parroquia=="030354"
    return "Rural" if id_parroquia=="030355"
    return "Rural" if id_parroquia=="030356"
    return "Rural" if id_parroquia=="030357"
    return "Rural" if id_parroquia=="030358"
    return "Rural" if id_parroquia=="030361"
    return "Rural" if id_parroquia=="030362"
    return "Rural" if id_parroquia=="030363"
    return "Rural" if id_parroquia=="030450"
    return "Rural" if id_parroquia=="030451"
    return "Rural" if id_parroquia=="030452"
    return "Rural" if id_parroquia=="030550"
    return "Rural" if id_parroquia=="030650"
    return "Rural" if id_parroquia=="030651"
    return "Rural" if id_parroquia=="030750"
    return "Rural" if id_parroquia=="040150"
    return "Rural" if id_parroquia=="040151"
    return "Rural" if id_parroquia=="040153"
    return "Rural" if id_parroquia=="040154"
    return "Rural" if id_parroquia=="040155"
    return "Rural" if id_parroquia=="040156"
    return "Rural" if id_parroquia=="040157"
    return "Rural" if id_parroquia=="040158"
    return "Rural" if id_parroquia=="040159"
    return "Rural" if id_parroquia=="040161"
    return "Rural" if id_parroquia=="040250"
    return "Rural" if id_parroquia=="040251"
    return "Rural" if id_parroquia=="040252"
    return "Rural" if id_parroquia=="040253"
    return "Rural" if id_parroquia=="040254"
    return "Rural" if id_parroquia=="040255"
    return "Rural" if id_parroquia=="040350"
    return "Rural" if id_parroquia=="040351"
    return "Rural" if id_parroquia=="040352"
    return "Rural" if id_parroquia=="040353"
    return "Rural" if id_parroquia=="040450"
    return "Rural" if id_parroquia=="040451"
    return "Rural" if id_parroquia=="040452"
    return "Rural" if id_parroquia=="040453"
    return "Rural" if id_parroquia=="040550"
    return "Rural" if id_parroquia=="040551"
    return "Rural" if id_parroquia=="040552"
    return "Rural" if id_parroquia=="040553"
    return "Rural" if id_parroquia=="040554"
    return "Rural" if id_parroquia=="040555"
    return "Rural" if id_parroquia=="040650"
    return "Rural" if id_parroquia=="040651"
    return "Rural" if id_parroquia=="050150"
    return "Rural" if id_parroquia=="050151"
    return "Rural" if id_parroquia=="050152"
    return "Rural" if id_parroquia=="050153"
    return "Rural" if id_parroquia=="050154"
    return "Rural" if id_parroquia=="050156"
    return "Rural" if id_parroquia=="050157"
    return "Rural" if id_parroquia=="050158"
    return "Rural" if id_parroquia=="050159"
    return "Rural" if id_parroquia=="050161"
    return "Rural" if id_parroquia=="050162"
    return "Rural" if id_parroquia=="050250"
    return "Rural" if id_parroquia=="050251"
    return "Rural" if id_parroquia=="050252"
    return "Rural" if id_parroquia=="050350"
    return "Rural" if id_parroquia=="050351"
    return "Rural" if id_parroquia=="050352"
    return "Rural" if id_parroquia=="050353"
    return "Rural" if id_parroquia=="050450"
    return "Rural" if id_parroquia=="050451"
    return "Rural" if id_parroquia=="050453"
    return "Rural" if id_parroquia=="050455"
    return "Rural" if id_parroquia=="050456"
    return "Rural" if id_parroquia=="050457"
    return "Rural" if id_parroquia=="050458"
    return "Rural" if id_parroquia=="050550"
    return "Rural" if id_parroquia=="050551"
    return "Rural" if id_parroquia=="050552"
    return "Rural" if id_parroquia=="050553"
    return "Rural" if id_parroquia=="050554"
    return "Rural" if id_parroquia=="050555"
    return "Rural" if id_parroquia=="050650"
    return "Rural" if id_parroquia=="050651"
    return "Rural" if id_parroquia=="050652"
    return "Rural" if id_parroquia=="050653"
    return "Rural" if id_parroquia=="050750"
    return "Rural" if id_parroquia=="050751"
    return "Rural" if id_parroquia=="050752"
    return "Rural" if id_parroquia=="050753"
    return "Rural" if id_parroquia=="050754"
    return "Rural" if id_parroquia=="060150"
    return "Rural" if id_parroquia=="060151"
    return "Rural" if id_parroquia=="060152"
    return "Rural" if id_parroquia=="060153"
    return "Rural" if id_parroquia=="060154"
    return "Rural" if id_parroquia=="060155"
    return "Rural" if id_parroquia=="060156"
    return "Rural" if id_parroquia=="060157"
    return "Rural" if id_parroquia=="060158"
    return "Rural" if id_parroquia=="060159"
    return "Rural" if id_parroquia=="060160"
    return "Rural" if id_parroquia=="060161"
    return "Rural" if id_parroquia=="060250"
    return "Rural" if id_parroquia=="060251"
    return "Rural" if id_parroquia=="060253"
    return "Rural" if id_parroquia=="060254"
    return "Rural" if id_parroquia=="060255"
    return "Rural" if id_parroquia=="060256"
    return "Rural" if id_parroquia=="060257"
    return "Rural" if id_parroquia=="060258"
    return "Rural" if id_parroquia=="060259"
    return "Rural" if id_parroquia=="060260"
    return "Rural" if id_parroquia=="060350"
    return "Rural" if id_parroquia=="060351"
    return "Rural" if id_parroquia=="060352"
    return "Rural" if id_parroquia=="060353"
    return "Rural" if id_parroquia=="060354"
    return "Rural" if id_parroquia=="060450"
    return "Rural" if id_parroquia=="060550"
    return "Rural" if id_parroquia=="060551"
    return "Rural" if id_parroquia=="060552"
    return "Rural" if id_parroquia=="060553"
    return "Rural" if id_parroquia=="060554"
    return "Rural" if id_parroquia=="060650"
    return "Rural" if id_parroquia=="060651"
    return "Rural" if id_parroquia=="060652"
    return "Rural" if id_parroquia=="060750"
    return "Rural" if id_parroquia=="060751"
    return "Rural" if id_parroquia=="060752"
    return "Rural" if id_parroquia=="060753"
    return "Rural" if id_parroquia=="060754"
    return "Rural" if id_parroquia=="060755"
    return "Rural" if id_parroquia=="060756"
    return "Rural" if id_parroquia=="060757"
    return "Rural" if id_parroquia=="060758"
    return "Rural" if id_parroquia=="060759"
    return "Rural" if id_parroquia=="060850"
    return "Rural" if id_parroquia=="060950"
    return "Rural" if id_parroquia=="060951"
    return "Rural" if id_parroquia=="060952"
    return "Rural" if id_parroquia=="060953"
    return "Rural" if id_parroquia=="060954"
    return "Rural" if id_parroquia=="060955"
    return "Rural" if id_parroquia=="060956"
    return "Rural" if id_parroquia=="061050"
    return "Rural" if id_parroquia=="070150"
    return "Rural" if id_parroquia=="070152"
    return "Rural" if id_parroquia=="070250"
    return "Rural" if id_parroquia=="070251"
    return "Rural" if id_parroquia=="070254"
    return "Rural" if id_parroquia=="070255"
    return "Rural" if id_parroquia=="070350"
    return "Rural" if id_parroquia=="070351"
    return "Rural" if id_parroquia=="070352"
    return "Rural" if id_parroquia=="070353"
    return "Rural" if id_parroquia=="070354"
    return "Rural" if id_parroquia=="070355"
    return "Rural" if id_parroquia=="070450"
    return "Rural" if id_parroquia=="070451"
    return "Rural" if id_parroquia=="070550"
    return "Rural" if id_parroquia=="070650"
    return "Rural" if id_parroquia=="070651"
    return "Rural" if id_parroquia=="070652"
    return "Rural" if id_parroquia=="070653"
    return "Rural" if id_parroquia=="070654"
    return "Rural" if id_parroquia=="070750"
    return "Rural" if id_parroquia=="070850"
    return "Rural" if id_parroquia=="070851"
    return "Rural" if id_parroquia=="070950"
    return "Rural" if id_parroquia=="070951"
    return "Rural" if id_parroquia=="070952"
    return "Rural" if id_parroquia=="070953"
    return "Rural" if id_parroquia=="070954"
    return "Rural" if id_parroquia=="070955"
    return "Rural" if id_parroquia=="070956"
    return "Rural" if id_parroquia=="071050"
    return "Rural" if id_parroquia=="071051"
    return "Rural" if id_parroquia=="071052"
    return "Rural" if id_parroquia=="071053"
    return "Rural" if id_parroquia=="071054"
    return "Rural" if id_parroquia=="071055"
    return "Rural" if id_parroquia=="071056"
    return "Rural" if id_parroquia=="071150"
    return "Rural" if id_parroquia=="071151"
    return "Rural" if id_parroquia=="071152"
    return "Rural" if id_parroquia=="071153"
    return "Rural" if id_parroquia=="071250"
    return "Rural" if id_parroquia=="071251"
    return "Rural" if id_parroquia=="071252"
    return "Rural" if id_parroquia=="071253"
    return "Rural" if id_parroquia=="071254"
    return "Rural" if id_parroquia=="071255"
    return "Rural" if id_parroquia=="071256"
    return "Rural" if id_parroquia=="071257"
    return "Rural" if id_parroquia=="071350"
    return "Rural" if id_parroquia=="071351"
    return "Rural" if id_parroquia=="071352"
    return "Rural" if id_parroquia=="071353"
    return "Rural" if id_parroquia=="071354"
    return "Rural" if id_parroquia=="071355"
    return "Rural" if id_parroquia=="071356"
    return "Rural" if id_parroquia=="071357"
    return "Rural" if id_parroquia=="071358"
    return "Rural" if id_parroquia=="071359"
    return "Rural" if id_parroquia=="071450"
    return "Rural" if id_parroquia=="071451"
    return "Rural" if id_parroquia=="071452"
    return "Rural" if id_parroquia=="071453"
    return "Rural" if id_parroquia=="080150"
    return "Rural" if id_parroquia=="080152"
    return "Rural" if id_parroquia=="080153"
    return "Rural" if id_parroquia=="080154"
    return "Rural" if id_parroquia=="080159"
    return "Rural" if id_parroquia=="080163"
    return "Rural" if id_parroquia=="080165"
    return "Rural" if id_parroquia=="080166"
    return "Rural" if id_parroquia=="080168"
    return "Rural" if id_parroquia=="080250"
    return "Rural" if id_parroquia=="080251"
    return "Rural" if id_parroquia=="080252"
    return "Rural" if id_parroquia=="080253"
    return "Rural" if id_parroquia=="080254"
    return "Rural" if id_parroquia=="080255"
    return "Rural" if id_parroquia=="080256"
    return "Rural" if id_parroquia=="080257"
    return "Rural" if id_parroquia=="080258"
    return "Rural" if id_parroquia=="080259"
    return "Rural" if id_parroquia=="080260"
    return "Rural" if id_parroquia=="080261"
    return "Rural" if id_parroquia=="080262"
    return "Rural" if id_parroquia=="080263"
    return "Rural" if id_parroquia=="080264"
    return "Rural" if id_parroquia=="080265"
    return "Rural" if id_parroquia=="080350"
    return "Rural" if id_parroquia=="080351"
    return "Rural" if id_parroquia=="080352"
    return "Rural" if id_parroquia=="080353"
    return "Rural" if id_parroquia=="080354"
    return "Rural" if id_parroquia=="080355"
    return "Rural" if id_parroquia=="080356"
    return "Rural" if id_parroquia=="080357"
    return "Rural" if id_parroquia=="080358"
    return "Rural" if id_parroquia=="080450"
    return "Rural" if id_parroquia=="080451"
    return "Rural" if id_parroquia=="080452"
    return "Rural" if id_parroquia=="080453"
    return "Rural" if id_parroquia=="080454"
    return "Rural" if id_parroquia=="080455"
    return "Rural" if id_parroquia=="080550"
    return "Rural" if id_parroquia=="080551"
    return "Rural" if id_parroquia=="080552"
    return "Rural" if id_parroquia=="080553"
    return "Rural" if id_parroquia=="080554"
    return "Rural" if id_parroquia=="080555"
    return "Rural" if id_parroquia=="080556"
    return "Rural" if id_parroquia=="080557"
    return "Rural" if id_parroquia=="080558"
    return "Rural" if id_parroquia=="080559"
    return "Rural" if id_parroquia=="080560"
    return "Rural" if id_parroquia=="080561"
    return "Rural" if id_parroquia=="080562"
    return "Rural" if id_parroquia=="080650"
    return "Rural" if id_parroquia=="080651"
    return "Rural" if id_parroquia=="080652"
    return "Rural" if id_parroquia=="080653"
    return "Rural" if id_parroquia=="080654"
    return "Rural" if id_parroquia=="080750"
    return "Rural" if id_parroquia=="080751"
    return "Rural" if id_parroquia=="080752"
    return "Rural" if id_parroquia=="080753"
    return "Rural" if id_parroquia=="080754"
    return "Rural" if id_parroquia=="080755"
    return "Rural" if id_parroquia=="090150"
    return "Rural" if id_parroquia=="090152"
    return "Rural" if id_parroquia=="090153"
    return "Rural" if id_parroquia=="090156"
    return "Rural" if id_parroquia=="090157"
    return "Rural" if id_parroquia=="090158"
    return "Rural" if id_parroquia=="090250"
    return "Rural" if id_parroquia=="090350"
    return "Rural" if id_parroquia=="090450"
    return "Rural" if id_parroquia=="090550"
    return "Rural" if id_parroquia=="090551"
    return "Rural" if id_parroquia=="090650"
    return "Rural" if id_parroquia=="090652"
    return "Rural" if id_parroquia=="090653"
    return "Rural" if id_parroquia=="090654"
    return "Rural" if id_parroquia=="090656"
    return "Rural" if id_parroquia=="090750"
    return "Rural" if id_parroquia=="090850"
    return "Rural" if id_parroquia=="090851"
    return "Rural" if id_parroquia=="090852"
    return "Rural" if id_parroquia=="090950"
    return "Rural" if id_parroquia=="091050"
    return "Rural" if id_parroquia=="091051"
    return "Rural" if id_parroquia=="091053"
    return "Rural" if id_parroquia=="091054"
    return "Rural" if id_parroquia=="091150"
    return "Rural" if id_parroquia=="091151"
    return "Rural" if id_parroquia=="091152"
    return "Rural" if id_parroquia=="091153"
    return "Rural" if id_parroquia=="091154"
    return "Rural" if id_parroquia=="091250"
    return "Rural" if id_parroquia=="091350"
    return "Rural" if id_parroquia=="091450"
    return "Rural" if id_parroquia=="091451"
    return "Rural" if id_parroquia=="091452"
    return "Rural" if id_parroquia=="091650"
    return "Rural" if id_parroquia=="091651"
    return "Rural" if id_parroquia=="091850"
    return "Rural" if id_parroquia=="091950"
    return "Rural" if id_parroquia=="091951"
    return "Rural" if id_parroquia=="091952"
    return "Rural" if id_parroquia=="091953"
    return "Rural" if id_parroquia=="092050"
    return "Rural" if id_parroquia=="092053"
    return "Rural" if id_parroquia=="092055"
    return "Rural" if id_parroquia=="092056"
    return "Rural" if id_parroquia=="092150"
    return "Rural" if id_parroquia=="092250"
    return "Rural" if id_parroquia=="092251"
    return "Rural" if id_parroquia=="092350"
    return "Rural" if id_parroquia=="092450"
    return "Rural" if id_parroquia=="092550"
    return "Rural" if id_parroquia=="092750"
    return "Rural" if id_parroquia=="092850"
    return "Rural" if id_parroquia=="100150"
    return "Rural" if id_parroquia=="100151"
    return "Rural" if id_parroquia=="100152"
    return "Rural" if id_parroquia=="100153"
    return "Rural" if id_parroquia=="100154"
    return "Rural" if id_parroquia=="100155"
    return "Rural" if id_parroquia=="100156"
    return "Rural" if id_parroquia=="100157"
    return "Rural" if id_parroquia=="100250"
    return "Rural" if id_parroquia=="100251"
    return "Rural" if id_parroquia=="100252"
    return "Rural" if id_parroquia=="100253"
    return "Rural" if id_parroquia=="100254"
    return "Rural" if id_parroquia=="100350"
    return "Rural" if id_parroquia=="100351"
    return "Rural" if id_parroquia=="100352"
    return "Rural" if id_parroquia=="100353"
    return "Rural" if id_parroquia=="100354"
    return "Rural" if id_parroquia=="100355"
    return "Rural" if id_parroquia=="100356"
    return "Rural" if id_parroquia=="100357"
    return "Rural" if id_parroquia=="100358"
    return "Rural" if id_parroquia=="100450"
    return "Rural" if id_parroquia=="100451"
    return "Rural" if id_parroquia=="100452"
    return "Rural" if id_parroquia=="100453"
    return "Rural" if id_parroquia=="100454"
    return "Rural" if id_parroquia=="100455"
    return "Rural" if id_parroquia=="100456"
    return "Rural" if id_parroquia=="100457"
    return "Rural" if id_parroquia=="100458"
    return "Rural" if id_parroquia=="100459"
    return "Rural" if id_parroquia=="100550"
    return "Rural" if id_parroquia=="100551"
    return "Rural" if id_parroquia=="100552"
    return "Rural" if id_parroquia=="100553"
    return "Rural" if id_parroquia=="100650"
    return "Rural" if id_parroquia=="100651"
    return "Rural" if id_parroquia=="100652"
    return "Rural" if id_parroquia=="100653"
    return "Rural" if id_parroquia=="100654"
    return "Rural" if id_parroquia=="100655"
    return "Rural" if id_parroquia=="110150"
    return "Rural" if id_parroquia=="110151"
    return "Rural" if id_parroquia=="110152"
    return "Rural" if id_parroquia=="110153"
    return "Rural" if id_parroquia=="110154"
    return "Rural" if id_parroquia=="110155"
    return "Rural" if id_parroquia=="110156"
    return "Rural" if id_parroquia=="110157"
    return "Rural" if id_parroquia=="110158"
    return "Rural" if id_parroquia=="110159"
    return "Rural" if id_parroquia=="110160"
    return "Rural" if id_parroquia=="110161"
    return "Rural" if id_parroquia=="110162"
    return "Rural" if id_parroquia=="110163"
    return "Rural" if id_parroquia=="110250"
    return "Rural" if id_parroquia=="110251"
    return "Rural" if id_parroquia=="110252"
    return "Rural" if id_parroquia=="110253"
    return "Rural" if id_parroquia=="110254"
    return "Rural" if id_parroquia=="110350"
    return "Rural" if id_parroquia=="110351"
    return "Rural" if id_parroquia=="110352"
    return "Rural" if id_parroquia=="110353"
    return "Rural" if id_parroquia=="110354"
    return "Rural" if id_parroquia=="110450"
    return "Rural" if id_parroquia=="110451"
    return "Rural" if id_parroquia=="110455"
    return "Rural" if id_parroquia=="110456"
    return "Rural" if id_parroquia=="110457"
    return "Rural" if id_parroquia=="110550"
    return "Rural" if id_parroquia=="110551"
    return "Rural" if id_parroquia=="110552"
    return "Rural" if id_parroquia=="110553"
    return "Rural" if id_parroquia=="110554"
    return "Rural" if id_parroquia=="110650"
    return "Rural" if id_parroquia=="110651"
    return "Rural" if id_parroquia=="110652"
    return "Rural" if id_parroquia=="110653"
    return "Rural" if id_parroquia=="110654"
    return "Rural" if id_parroquia=="110655"
    return "Rural" if id_parroquia=="110656"
    return "Rural" if id_parroquia=="110750"
    return "Rural" if id_parroquia=="110751"
    return "Rural" if id_parroquia=="110753"
    return "Rural" if id_parroquia=="110754"
    return "Rural" if id_parroquia=="110756"
    return "Rural" if id_parroquia=="110850"
    return "Rural" if id_parroquia=="110851"
    return "Rural" if id_parroquia=="110852"
    return "Rural" if id_parroquia=="110853"
    return "Rural" if id_parroquia=="110950"
    return "Rural" if id_parroquia=="110951"
    return "Rural" if id_parroquia=="110952"
    return "Rural" if id_parroquia=="110954"
    return "Rural" if id_parroquia=="110956"
    return "Rural" if id_parroquia=="110957"
    return "Rural" if id_parroquia=="110958"
    return "Rural" if id_parroquia=="110959"
    return "Rural" if id_parroquia=="111050"
    return "Rural" if id_parroquia=="111051"
    return "Rural" if id_parroquia=="111052"
    return "Rural" if id_parroquia=="111053"
    return "Rural" if id_parroquia=="111054"
    return "Rural" if id_parroquia=="111055"
    return "Rural" if id_parroquia=="111150"
    return "Rural" if id_parroquia=="111151"
    return "Rural" if id_parroquia=="111152"
    return "Rural" if id_parroquia=="111153"
    return "Rural" if id_parroquia=="111154"
    return "Rural" if id_parroquia=="111155"
    return "Rural" if id_parroquia=="111156"
    return "Rural" if id_parroquia=="111157"
    return "Rural" if id_parroquia=="111158"
    return "Rural" if id_parroquia=="111159"
    return "Rural" if id_parroquia=="111160"
    return "Rural" if id_parroquia=="111250"
    return "Rural" if id_parroquia=="111251"
    return "Rural" if id_parroquia=="111252"
    return "Rural" if id_parroquia=="111350"
    return "Rural" if id_parroquia=="111351"
    return "Rural" if id_parroquia=="111352"
    return "Rural" if id_parroquia=="111353"
    return "Rural" if id_parroquia=="111354"
    return "Rural" if id_parroquia=="111355"
    return "Rural" if id_parroquia=="111356"
    return "Rural" if id_parroquia=="111450"
    return "Rural" if id_parroquia=="111451"
    return "Rural" if id_parroquia=="111452"
    return "Rural" if id_parroquia=="111453"
    return "Rural" if id_parroquia=="111550"
    return "Rural" if id_parroquia=="111551"
    return "Rural" if id_parroquia=="111552"
    return "Rural" if id_parroquia=="111650"
    return "Rural" if id_parroquia=="111651"
    return "Rural" if id_parroquia=="120150"
    return "Rural" if id_parroquia=="120152"
    return "Rural" if id_parroquia=="120153"
    return "Rural" if id_parroquia=="120154"
    return "Rural" if id_parroquia=="120155"
    return "Rural" if id_parroquia=="120250"
    return "Rural" if id_parroquia=="120251"
    return "Rural" if id_parroquia=="120252"
    return "Rural" if id_parroquia=="120350"
    return "Rural" if id_parroquia=="120351"
    return "Rural" if id_parroquia=="120450"
    return "Rural" if id_parroquia=="120451"
    return "Rural" if id_parroquia=="120452"
    return "Rural" if id_parroquia=="120550"
    return "Rural" if id_parroquia=="120553"
    return "Rural" if id_parroquia=="120555"
    return "Rural" if id_parroquia=="120650"
    return "Rural" if id_parroquia=="120651"
    return "Rural" if id_parroquia=="120750"
    return "Rural" if id_parroquia=="120752"
    return "Rural" if id_parroquia=="120753"
    return "Rural" if id_parroquia=="120754"
    return "Rural" if id_parroquia=="120850"
    return "Rural" if id_parroquia=="120851"
    return "Rural" if id_parroquia=="120950"
    return "Rural" if id_parroquia=="121050"
    return "Rural" if id_parroquia=="121051"
    return "Rural" if id_parroquia=="121150"
    return "Rural" if id_parroquia=="121250"
    return "Rural" if id_parroquia=="121350"
    return "Rural" if id_parroquia=="130150"
    return "Rural" if id_parroquia=="130151"
    return "Rural" if id_parroquia=="130152"
    return "Rural" if id_parroquia=="130153"
    return "Rural" if id_parroquia=="130154"
    return "Rural" if id_parroquia=="130155"
    return "Rural" if id_parroquia=="130156"
    return "Rural" if id_parroquia=="130157"
    return "Rural" if id_parroquia=="130250"
    return "Rural" if id_parroquia=="130251"
    return "Rural" if id_parroquia=="130252"
    return "Rural" if id_parroquia=="130350"
    return "Rural" if id_parroquia=="130351"
    return "Rural" if id_parroquia=="130352"
    return "Rural" if id_parroquia=="130353"
    return "Rural" if id_parroquia=="130354"
    return "Rural" if id_parroquia=="130355"
    return "Rural" if id_parroquia=="130356"
    return "Rural" if id_parroquia=="130357"
    return "Rural" if id_parroquia=="130450"
    return "Rural" if id_parroquia=="130451"
    return "Rural" if id_parroquia=="130452"
    return "Rural" if id_parroquia=="130550"
    return "Rural" if id_parroquia=="130551"
    return "Rural" if id_parroquia=="130552"
    return "Rural" if id_parroquia=="130650"
    return "Rural" if id_parroquia=="130651"
    return "Rural" if id_parroquia=="130652"
    return "Rural" if id_parroquia=="130653"
    return "Rural" if id_parroquia=="130654"
    return "Rural" if id_parroquia=="130656"
    return "Rural" if id_parroquia=="130657"
    return "Rural" if id_parroquia=="130658"
    return "Rural" if id_parroquia=="130750"
    return "Rural" if id_parroquia=="130850"
    return "Rural" if id_parroquia=="130851"
    return "Rural" if id_parroquia=="130852"
    return "Rural" if id_parroquia=="130950"
    return "Rural" if id_parroquia=="130952"
    return "Rural" if id_parroquia=="131050"
    return "Rural" if id_parroquia=="131051"
    return "Rural" if id_parroquia=="131052"
    return "Rural" if id_parroquia=="131053"
    return "Rural" if id_parroquia=="131054"
    return "Rural" if id_parroquia=="131150"
    return "Rural" if id_parroquia=="131151"
    return "Rural" if id_parroquia=="131152"
    return "Rural" if id_parroquia=="131250"
    return "Rural" if id_parroquia=="131350"
    return "Rural" if id_parroquia=="131351"
    return "Rural" if id_parroquia=="131352"
    return "Rural" if id_parroquia=="131353"
    return "Rural" if id_parroquia=="131355"
    return "Rural" if id_parroquia=="131450"
    return "Rural" if id_parroquia=="131453"
    return "Rural" if id_parroquia=="131457"
    return "Rural" if id_parroquia=="131550"
    return "Rural" if id_parroquia=="131551"
    return "Rural" if id_parroquia=="131552"
    return "Rural" if id_parroquia=="131650"
    return "Rural" if id_parroquia=="131651"
    return "Rural" if id_parroquia=="131652"
    return "Rural" if id_parroquia=="131653"
    return "Rural" if id_parroquia=="131750"
    return "Rural" if id_parroquia=="131751"
    return "Rural" if id_parroquia=="131752"
    return "Rural" if id_parroquia=="131753"
    return "Rural" if id_parroquia=="131850"
    return "Rural" if id_parroquia=="131950"
    return "Rural" if id_parroquia=="131951"
    return "Rural" if id_parroquia=="131952"
    return "Rural" if id_parroquia=="132050"
    return "Rural" if id_parroquia=="132150"
    return "Rural" if id_parroquia=="132250"
    return "Rural" if id_parroquia=="132251"
    return "Rural" if id_parroquia=="140150"
    return "Rural" if id_parroquia=="140151"
    return "Rural" if id_parroquia=="140153"
    return "Rural" if id_parroquia=="140156"
    return "Rural" if id_parroquia=="140157"
    return "Rural" if id_parroquia=="140158"
    return "Rural" if id_parroquia=="140160"
    return "Rural" if id_parroquia=="140162"
    return "Rural" if id_parroquia=="140164"
    return "Rural" if id_parroquia=="140250"
    return "Rural" if id_parroquia=="140251"
    return "Rural" if id_parroquia=="140252"
    return "Rural" if id_parroquia=="140253"
    return "Rural" if id_parroquia=="140254"
    return "Rural" if id_parroquia=="140255"
    return "Rural" if id_parroquia=="140256"
    return "Rural" if id_parroquia=="140257"
    return "Rural" if id_parroquia=="140258"
    return "Rural" if id_parroquia=="140350"
    return "Rural" if id_parroquia=="140351"
    return "Rural" if id_parroquia=="140353"
    return "Rural" if id_parroquia=="140356"
    return "Rural" if id_parroquia=="140357"
    return "Rural" if id_parroquia=="140358"
    return "Rural" if id_parroquia=="140450"
    return "Rural" if id_parroquia=="140451"
    return "Rural" if id_parroquia=="140452"
    return "Rural" if id_parroquia=="140454"
    return "Rural" if id_parroquia=="140455"
    return "Rural" if id_parroquia=="140550"
    return "Rural" if id_parroquia=="140551"
    return "Rural" if id_parroquia=="140552"
    return "Rural" if id_parroquia=="140553"
    return "Rural" if id_parroquia=="140554"
    return "Rural" if id_parroquia=="140556"
    return "Rural" if id_parroquia=="140557"
    return "Rural" if id_parroquia=="140650"
    return "Rural" if id_parroquia=="140651"
    return "Rural" if id_parroquia=="140652"
    return "Rural" if id_parroquia=="140655"
    return "Rural" if id_parroquia=="140750"
    return "Rural" if id_parroquia=="140751"
    return "Rural" if id_parroquia=="140850"
    return "Rural" if id_parroquia=="140851"
    return "Rural" if id_parroquia=="140852"
    return "Rural" if id_parroquia=="140853"
    return "Rural" if id_parroquia=="140854"
    return "Rural" if id_parroquia=="140950"
    return "Rural" if id_parroquia=="140951"
    return "Rural" if id_parroquia=="140952"
    return "Rural" if id_parroquia=="140953"
    return "Rural" if id_parroquia=="140954"
    return "Rural" if id_parroquia=="141050"
    return "Rural" if id_parroquia=="141051"
    return "Rural" if id_parroquia=="141052"
    return "Rural" if id_parroquia=="141150"
    return "Rural" if id_parroquia=="141250"
    return "Rural" if id_parroquia=="141251"
    return "Rural" if id_parroquia=="150150"
    return "Rural" if id_parroquia=="150151"
    return "Rural" if id_parroquia=="150153"
    return "Rural" if id_parroquia=="150154"
    return "Rural" if id_parroquia=="150155"
    return "Rural" if id_parroquia=="150156"
    return "Rural" if id_parroquia=="150157"
    return "Rural" if id_parroquia=="150158"
    return "Rural" if id_parroquia=="150350"
    return "Rural" if id_parroquia=="150352"
    return "Rural" if id_parroquia=="150354"
    return "Rural" if id_parroquia=="150356"
    return "Rural" if id_parroquia=="150450"
    return "Rural" if id_parroquia=="150451"
    return "Rural" if id_parroquia=="150452"
    return "Rural" if id_parroquia=="150453"
    return "Rural" if id_parroquia=="150454"
    return "Rural" if id_parroquia=="150455"
    return "Rural" if id_parroquia=="150750"
    return "Rural" if id_parroquia=="150751"
    return "Rural" if id_parroquia=="150752"
    return "Rural" if id_parroquia=="150753"
    return "Rural" if id_parroquia=="150754"
    return "Rural" if id_parroquia=="150756"
    return "Rural" if id_parroquia=="150950"
    return "Rural" if id_parroquia=="160150"
    return "Rural" if id_parroquia=="160152"
    return "Rural" if id_parroquia=="160154"
    return "Rural" if id_parroquia=="160155"
    return "Rural" if id_parroquia=="160156"
    return "Rural" if id_parroquia=="160157"
    return "Rural" if id_parroquia=="160158"
    return "Rural" if id_parroquia=="160159"
    return "Rural" if id_parroquia=="160161"
    return "Rural" if id_parroquia=="160162"
    return "Rural" if id_parroquia=="160163"
    return "Rural" if id_parroquia=="160164"
    return "Rural" if id_parroquia=="160165"
    return "Rural" if id_parroquia=="160166"
    return "Rural" if id_parroquia=="160250"
    return "Rural" if id_parroquia=="160251"
    return "Rural" if id_parroquia=="160252"
    return "Rural" if id_parroquia=="160350"
    return "Rural" if id_parroquia=="160351"
    return "Rural" if id_parroquia=="160450"
    return "Rural" if id_parroquia=="160451"
    return "Rural" if id_parroquia=="170150"
    return "Rural" if id_parroquia=="170151"
    return "Rural" if id_parroquia=="170152"
    return "Rural" if id_parroquia=="170153"
    return "Rural" if id_parroquia=="170154"
    return "Rural" if id_parroquia=="170155"
    return "Rural" if id_parroquia=="170156"
    return "Rural" if id_parroquia=="170157"
    return "Rural" if id_parroquia=="170158"
    return "Rural" if id_parroquia=="170159"
    return "Rural" if id_parroquia=="170160"
    return "Rural" if id_parroquia=="170161"
    return "Rural" if id_parroquia=="170162"
    return "Rural" if id_parroquia=="170163"
    return "Rural" if id_parroquia=="170164"
    return "Rural" if id_parroquia=="170165"
    return "Rural" if id_parroquia=="170166"
    return "Rural" if id_parroquia=="170168"
    return "Rural" if id_parroquia=="170169"
    return "Rural" if id_parroquia=="170170"
    return "Rural" if id_parroquia=="170171"
    return "Rural" if id_parroquia=="170172"
    return "Rural" if id_parroquia=="170174"
    return "Rural" if id_parroquia=="170175"
    return "Rural" if id_parroquia=="170176"
    return "Rural" if id_parroquia=="170177"
    return "Rural" if id_parroquia=="170178"
    return "Rural" if id_parroquia=="170179"
    return "Rural" if id_parroquia=="170180"
    return "Rural" if id_parroquia=="170181"
    return "Rural" if id_parroquia=="170183"
    return "Rural" if id_parroquia=="170184"
    return "Rural" if id_parroquia=="170185"
    return "Rural" if id_parroquia=="170186"
    return "Rural" if id_parroquia=="170250"
    return "Rural" if id_parroquia=="170251"
    return "Rural" if id_parroquia=="170252"
    return "Rural" if id_parroquia=="170253"
    return "Rural" if id_parroquia=="170254"
    return "Rural" if id_parroquia=="170255"
    return "Rural" if id_parroquia=="170256"
    return "Rural" if id_parroquia=="170350"
    return "Rural" if id_parroquia=="170351"
    return "Rural" if id_parroquia=="170352"
    return "Rural" if id_parroquia=="170353"
    return "Rural" if id_parroquia=="170354"
    return "Rural" if id_parroquia=="170355"
    return "Rural" if id_parroquia=="170356"
    return "Rural" if id_parroquia=="170357"
    return "Rural" if id_parroquia=="170450"
    return "Rural" if id_parroquia=="170451"
    return "Rural" if id_parroquia=="170452"
    return "Rural" if id_parroquia=="170453"
    return "Rural" if id_parroquia=="170454"
    return "Rural" if id_parroquia=="170550"
    return "Rural" if id_parroquia=="170551"
    return "Rural" if id_parroquia=="170552"
    return "Rural" if id_parroquia=="170750"
    return "Rural" if id_parroquia=="170751"
    return "Rural" if id_parroquia=="170850"
    return "Rural" if id_parroquia=="170950"
    return "Rural" if id_parroquia=="180150"
    return "Rural" if id_parroquia=="180151"
    return "Rural" if id_parroquia=="180152"
    return "Rural" if id_parroquia=="180153"
    return "Rural" if id_parroquia=="180154"
    return "Rural" if id_parroquia=="180155"
    return "Rural" if id_parroquia=="180156"
    return "Rural" if id_parroquia=="180157"
    return "Rural" if id_parroquia=="180158"
    return "Rural" if id_parroquia=="180159"
    return "Rural" if id_parroquia=="180160"
    return "Rural" if id_parroquia=="180161"
    return "Rural" if id_parroquia=="180162"
    return "Rural" if id_parroquia=="180163"
    return "Rural" if id_parroquia=="180164"
    return "Rural" if id_parroquia=="180165"
    return "Rural" if id_parroquia=="180166"
    return "Rural" if id_parroquia=="180167"
    return "Rural" if id_parroquia=="180168"
    return "Rural" if id_parroquia=="180250"
    return "Rural" if id_parroquia=="180251"
    return "Rural" if id_parroquia=="180252"
    return "Rural" if id_parroquia=="180253"
    return "Rural" if id_parroquia=="180254"
    return "Rural" if id_parroquia=="180350"
    return "Rural" if id_parroquia=="180450"
    return "Rural" if id_parroquia=="180451"
    return "Rural" if id_parroquia=="180550"
    return "Rural" if id_parroquia=="180551"
    return "Rural" if id_parroquia=="180552"
    return "Rural" if id_parroquia=="180553"
    return "Rural" if id_parroquia=="180650"
    return "Rural" if id_parroquia=="180651"
    return "Rural" if id_parroquia=="180652"
    return "Rural" if id_parroquia=="180750"
    return "Rural" if id_parroquia=="180751"
    return "Rural" if id_parroquia=="180752"
    return "Rural" if id_parroquia=="180753"
    return "Rural" if id_parroquia=="180754"
    return "Rural" if id_parroquia=="180755"
    return "Rural" if id_parroquia=="180756"
    return "Rural" if id_parroquia=="180757"
    return "Rural" if id_parroquia=="180758"
    return "Rural" if id_parroquia=="180850"
    return "Rural" if id_parroquia=="180851"
    return "Rural" if id_parroquia=="180852"
    return "Rural" if id_parroquia=="180853"
    return "Rural" if id_parroquia=="180854"
    return "Rural" if id_parroquia=="180855"
    return "Rural" if id_parroquia=="180856"
    return "Rural" if id_parroquia=="180857"
    return "Rural" if id_parroquia=="180950"
    return "Rural" if id_parroquia=="180951"
    return "Rural" if id_parroquia=="190150"
    return "Rural" if id_parroquia=="190151"
    return "Rural" if id_parroquia=="190152"
    return "Rural" if id_parroquia=="190153"
    return "Rural" if id_parroquia=="190155"
    return "Rural" if id_parroquia=="190156"
    return "Rural" if id_parroquia=="190158"
    return "Rural" if id_parroquia=="190250"
    return "Rural" if id_parroquia=="190251"
    return "Rural" if id_parroquia=="190252"
    return "Rural" if id_parroquia=="190254"
    return "Rural" if id_parroquia=="190256"
    return "Rural" if id_parroquia=="190259"
    return "Rural" if id_parroquia=="190350"
    return "Rural" if id_parroquia=="190351"
    return "Rural" if id_parroquia=="190352"
    return "Rural" if id_parroquia=="190450"
    return "Rural" if id_parroquia=="190451"
    return "Rural" if id_parroquia=="190452"
    return "Rural" if id_parroquia=="190550"
    return "Rural" if id_parroquia=="190551"
    return "Rural" if id_parroquia=="190553"
    return "Rural" if id_parroquia=="190650"
    return "Rural" if id_parroquia=="190651"
    return "Rural" if id_parroquia=="190652"
    return "Rural" if id_parroquia=="190653"
    return "Rural" if id_parroquia=="190750"
    return "Rural" if id_parroquia=="190752"
    return "Rural" if id_parroquia=="190753"
    return "Rural" if id_parroquia=="190850"
    return "Rural" if id_parroquia=="190851"
    return "Rural" if id_parroquia=="190852"
    return "Rural" if id_parroquia=="190853"
    return "Rural" if id_parroquia=="190854"
    return "Rural" if id_parroquia=="190950"
    return "Rural" if id_parroquia=="190951"
    return "Rural" if id_parroquia=="190952"
    return "Rural" if id_parroquia=="200150"
    return "Rural" if id_parroquia=="200151"
    return "Rural" if id_parroquia=="200152"
    return "Rural" if id_parroquia=="200250"
    return "Rural" if id_parroquia=="200251"
    return "Rural" if id_parroquia=="200350"
    return "Rural" if id_parroquia=="200351"
    return "Rural" if id_parroquia=="200352"
    return "Rural" if id_parroquia=="210150"
    return "Rural" if id_parroquia=="210152"
    return "Rural" if id_parroquia=="210153"
    return "Rural" if id_parroquia=="210155"
    return "Rural" if id_parroquia=="210156"
    return "Rural" if id_parroquia=="210157"
    return "Rural" if id_parroquia=="210158"
    return "Rural" if id_parroquia=="210160"
    return "Rural" if id_parroquia=="210250"
    return "Rural" if id_parroquia=="210251"
    return "Rural" if id_parroquia=="210252"
    return "Rural" if id_parroquia=="210254"
    return "Rural" if id_parroquia=="210350"
    return "Rural" if id_parroquia=="210351"
    return "Rural" if id_parroquia=="210352"
    return "Rural" if id_parroquia=="210353"
    return "Rural" if id_parroquia=="210354"
    return "Rural" if id_parroquia=="210450"
    return "Rural" if id_parroquia=="210451"
    return "Rural" if id_parroquia=="210452"
    return "Rural" if id_parroquia=="210453"
    return "Rural" if id_parroquia=="210454"
    return "Rural" if id_parroquia=="210455"
    return "Rural" if id_parroquia=="210550"
    return "Rural" if id_parroquia=="210551"
    return "Rural" if id_parroquia=="210552"
    return "Rural" if id_parroquia=="210553"
    return "Rural" if id_parroquia=="210554"
    return "Rural" if id_parroquia=="210650"
    return "Rural" if id_parroquia=="210651"
    return "Rural" if id_parroquia=="210652"
    return "Rural" if id_parroquia=="210750"
    return "Rural" if id_parroquia=="210751"
    return "Rural" if id_parroquia=="210752"
    return "Rural" if id_parroquia=="220150"
    return "Rural" if id_parroquia=="220151"
    return "Rural" if id_parroquia=="220152"
    return "Rural" if id_parroquia=="220153"
    return "Rural" if id_parroquia=="220154"
    return "Rural" if id_parroquia=="220155"
    return "Rural" if id_parroquia=="220156"
    return "Rural" if id_parroquia=="220157"
    return "Rural" if id_parroquia=="220158"
    return "Rural" if id_parroquia=="220159"
    return "Rural" if id_parroquia=="220160"
    return "Rural" if id_parroquia=="220161"
    return "Rural" if id_parroquia=="220250"
    return "Rural" if id_parroquia=="220251"
    return "Rural" if id_parroquia=="220252"
    return "Rural" if id_parroquia=="220253"
    return "Rural" if id_parroquia=="220254"
    return "Rural" if id_parroquia=="220255"
    return "Rural" if id_parroquia=="220350"
    return "Rural" if id_parroquia=="220351"
    return "Rural" if id_parroquia=="220352"
    return "Rural" if id_parroquia=="220353"
    return "Rural" if id_parroquia=="220354"
    return "Rural" if id_parroquia=="220355"
    return "Rural" if id_parroquia=="220356"
    return "Rural" if id_parroquia=="220357"
    return "Rural" if id_parroquia=="220358"
    return "Rural" if id_parroquia=="220450"
    return "Rural" if id_parroquia=="220451"
    return "Rural" if id_parroquia=="220452"
    return "Rural" if id_parroquia=="220453"
    return "Rural" if id_parroquia=="220454"
    return "Rural" if id_parroquia=="220455"
    return "Rural" if id_parroquia=="230150"
    return "Rural" if id_parroquia=="230151"
    return "Rural" if id_parroquia=="230152"
    return "Rural" if id_parroquia=="230153"
    return "Rural" if id_parroquia=="230154"
    return "Rural" if id_parroquia=="230155"
    return "Rural" if id_parroquia=="230156"
    return "Rural" if id_parroquia=="230157"
    return "Rural" if id_parroquia=="230250"
    return "Rural" if id_parroquia=="230251"
    return "Rural" if id_parroquia=="230252"
    return "Rural" if id_parroquia=="230253"
    return "Rural" if id_parroquia=="240150"
    return "Rural" if id_parroquia=="240151"
    return "Rural" if id_parroquia=="240152"
    return "Rural" if id_parroquia=="240153"
    return "Rural" if id_parroquia=="240154"
    return "Rural" if id_parroquia=="240155"
    return "Rural" if id_parroquia=="240156"
    return "Rural" if id_parroquia=="240250"
    return "Rural" if id_parroquia=="240350"
    return "Rural" if id_parroquia=="240351"
    return "Rural" if id_parroquia=="240352"
    return "Rural" if id_parroquia=="900151"
    return "Rural" if id_parroquia=="900451"
    return "Rural" if id_parroquia=="900551"
    return "Rural" if id_parroquia=="900651"
    return "Rural" if id_parroquia=="900751"
    return "Rural" if id_parroquia=="900851"
    return "Urbano" if id_parroquia=="010101"
    return "Urbano" if id_parroquia=="010102"
    return "Urbano" if id_parroquia=="010103"
    return "Urbano" if id_parroquia=="010104"
    return "Urbano" if id_parroquia=="010105"
    return "Urbano" if id_parroquia=="010106"
    return "Urbano" if id_parroquia=="010107"
    return "Urbano" if id_parroquia=="010108"
    return "Urbano" if id_parroquia=="010109"
    return "Urbano" if id_parroquia=="010110"
    return "Urbano" if id_parroquia=="010111"
    return "Urbano" if id_parroquia=="010112"
    return "Urbano" if id_parroquia=="010113"
    return "Urbano" if id_parroquia=="010114"
    return "Urbano" if id_parroquia=="010115"
    return "Urbano" if id_parroquia=="020101"
    return "Urbano" if id_parroquia=="020102"
    return "Urbano" if id_parroquia=="020103"
    return "Urbano" if id_parroquia=="020701"
    return "Urbano" if id_parroquia=="020702"
    return "Urbano" if id_parroquia=="030101"
    return "Urbano" if id_parroquia=="030102"
    return "Urbano" if id_parroquia=="030103"
    return "Urbano" if id_parroquia=="030104"
    return "Urbano" if id_parroquia=="040101"
    return "Urbano" if id_parroquia=="040102"
    return "Urbano" if id_parroquia=="040301"
    return "Urbano" if id_parroquia=="040302"
    return "Urbano" if id_parroquia=="040501"
    return "Urbano" if id_parroquia=="040502"
    return "Urbano" if id_parroquia=="050101"
    return "Urbano" if id_parroquia=="050102"
    return "Urbano" if id_parroquia=="050103"
    return "Urbano" if id_parroquia=="050104"
    return "Urbano" if id_parroquia=="050105"
    return "Urbano" if id_parroquia=="050201"
    return "Urbano" if id_parroquia=="050202"
    return "Urbano" if id_parroquia=="050203"
    return "Urbano" if id_parroquia=="060101"
    return "Urbano" if id_parroquia=="060102"
    return "Urbano" if id_parroquia=="060103"
    return "Urbano" if id_parroquia=="060104"
    return "Urbano" if id_parroquia=="060105"
    return "Urbano" if id_parroquia=="060301"
    return "Urbano" if id_parroquia=="060302"
    return "Urbano" if id_parroquia=="060701"
    return "Urbano" if id_parroquia=="060702"
    return "Urbano" if id_parroquia=="070101"
    return "Urbano" if id_parroquia=="070102"
    return "Urbano" if id_parroquia=="070103"
    return "Urbano" if id_parroquia=="070104"
    return "Urbano" if id_parroquia=="070105"
    return "Urbano" if id_parroquia=="070701"
    return "Urbano" if id_parroquia=="070702"
    return "Urbano" if id_parroquia=="070703"
    return "Urbano" if id_parroquia=="070704"
    return "Urbano" if id_parroquia=="070705"
    return "Urbano" if id_parroquia=="070901"
    return "Urbano" if id_parroquia=="070902"
    return "Urbano" if id_parroquia=="070903"
    return "Urbano" if id_parroquia=="070904"
    return "Urbano" if id_parroquia=="071001"
    return "Urbano" if id_parroquia=="071002"
    return "Urbano" if id_parroquia=="071003"
    return "Urbano" if id_parroquia=="071201"
    return "Urbano" if id_parroquia=="071202"
    return "Urbano" if id_parroquia=="071203"
    return "Urbano" if id_parroquia=="071204"
    return "Urbano" if id_parroquia=="071205"
    return "Urbano" if id_parroquia=="071401"
    return "Urbano" if id_parroquia=="071402"
    return "Urbano" if id_parroquia=="071403"
    return "Urbano" if id_parroquia=="080101"
    return "Urbano" if id_parroquia=="080102"
    return "Urbano" if id_parroquia=="080103"
    return "Urbano" if id_parroquia=="080104"
    return "Urbano" if id_parroquia=="080105"
    return "Urbano" if id_parroquia=="090101"
    return "Urbano" if id_parroquia=="090102"
    return "Urbano" if id_parroquia=="090103"
    return "Urbano" if id_parroquia=="090104"
    return "Urbano" if id_parroquia=="090105"
    return "Urbano" if id_parroquia=="090106"
    return "Urbano" if id_parroquia=="090107"
    return "Urbano" if id_parroquia=="090108"
    return "Urbano" if id_parroquia=="090109"
    return "Urbano" if id_parroquia=="090110"
    return "Urbano" if id_parroquia=="090111"
    return "Urbano" if id_parroquia=="090112"
    return "Urbano" if id_parroquia=="090113"
    return "Urbano" if id_parroquia=="090114"
    return "Urbano" if id_parroquia=="090115"
    return "Urbano" if id_parroquia=="090601"
    return "Urbano" if id_parroquia=="090602"
    return "Urbano" if id_parroquia=="090603"
    return "Urbano" if id_parroquia=="090604"
    return "Urbano" if id_parroquia=="090605"
    return "Urbano" if id_parroquia=="090606"
    return "Urbano" if id_parroquia=="090607"
    return "Urbano" if id_parroquia=="090608"
    return "Urbano" if id_parroquia=="090701"
    return "Urbano" if id_parroquia=="090702"
    return "Urbano" if id_parroquia=="090703"
    return "Urbano" if id_parroquia=="091001"
    return "Urbano" if id_parroquia=="091002"
    return "Urbano" if id_parroquia=="091003"
    return "Urbano" if id_parroquia=="091004"
    return "Urbano" if id_parroquia=="091005"
    return "Urbano" if id_parroquia=="091006"
    return "Urbano" if id_parroquia=="091007"
    return "Urbano" if id_parroquia=="091008"
    return "Urbano" if id_parroquia=="091009"
    return "Urbano" if id_parroquia=="091601"
    return "Urbano" if id_parroquia=="091602"
    return "Urbano" if id_parroquia=="091901"
    return "Urbano" if id_parroquia=="091902"
    return "Urbano" if id_parroquia=="091903"
    return "Urbano" if id_parroquia=="091904"
    return "Urbano" if id_parroquia=="091905"
    return "Urbano" if id_parroquia=="100101"
    return "Urbano" if id_parroquia=="100102"
    return "Urbano" if id_parroquia=="100103"
    return "Urbano" if id_parroquia=="100104"
    return "Urbano" if id_parroquia=="100105"
    return "Urbano" if id_parroquia=="100201"
    return "Urbano" if id_parroquia=="100202"
    return "Urbano" if id_parroquia=="100301"
    return "Urbano" if id_parroquia=="100302"
    return "Urbano" if id_parroquia=="100401"
    return "Urbano" if id_parroquia=="100402"
    return "Urbano" if id_parroquia=="110101"
    return "Urbano" if id_parroquia=="110102"
    return "Urbano" if id_parroquia=="110103"
    return "Urbano" if id_parroquia=="110104"
    return "Urbano" if id_parroquia=="110105"
    return "Urbano" if id_parroquia=="110106"
    return "Urbano" if id_parroquia=="110201"
    return "Urbano" if id_parroquia=="110202"
    return "Urbano" if id_parroquia=="110203"
    return "Urbano" if id_parroquia=="110301"
    return "Urbano" if id_parroquia=="110302"
    return "Urbano" if id_parroquia=="110801"
    return "Urbano" if id_parroquia=="110802"
    return "Urbano" if id_parroquia=="110901"
    return "Urbano" if id_parroquia=="110902"
    return "Urbano" if id_parroquia=="120101"
    return "Urbano" if id_parroquia=="120102"
    return "Urbano" if id_parroquia=="120103"
    return "Urbano" if id_parroquia=="120104"
    return "Urbano" if id_parroquia=="120501"
    return "Urbano" if id_parroquia=="120502"
    return "Urbano" if id_parroquia=="120504"
    return "Urbano" if id_parroquia=="120505"
    return "Urbano" if id_parroquia=="120506"
    return "Urbano" if id_parroquia=="120507"
    return "Urbano" if id_parroquia=="120508"
    return "Urbano" if id_parroquia=="120509"
    return "Urbano" if id_parroquia=="120510"
    return "Urbano" if id_parroquia=="120701"
    return "Urbano" if id_parroquia=="120702"
    return "Urbano" if id_parroquia=="120801"
    return "Urbano" if id_parroquia=="120802"
    return "Urbano" if id_parroquia=="120803"
    return "Urbano" if id_parroquia=="121001"
    return "Urbano" if id_parroquia=="121002"
    return "Urbano" if id_parroquia=="121003"
    return "Urbano" if id_parroquia=="121101"
    return "Urbano" if id_parroquia=="121102"
    return "Urbano" if id_parroquia=="121103"
    return "Urbano" if id_parroquia=="130101"
    return "Urbano" if id_parroquia=="130102"
    return "Urbano" if id_parroquia=="130103"
    return "Urbano" if id_parroquia=="130104"
    return "Urbano" if id_parroquia=="130105"
    return "Urbano" if id_parroquia=="130106"
    return "Urbano" if id_parroquia=="130107"
    return "Urbano" if id_parroquia=="130108"
    return "Urbano" if id_parroquia=="130109"
    return "Urbano" if id_parroquia=="130301"
    return "Urbano" if id_parroquia=="130302"
    return "Urbano" if id_parroquia=="130401"
    return "Urbano" if id_parroquia=="130402"
    return "Urbano" if id_parroquia=="130601"
    return "Urbano" if id_parroquia=="130602"
    return "Urbano" if id_parroquia=="130603"
    return "Urbano" if id_parroquia=="130801"
    return "Urbano" if id_parroquia=="130802"
    return "Urbano" if id_parroquia=="130803"
    return "Urbano" if id_parroquia=="130804"
    return "Urbano" if id_parroquia=="130805"
    return "Urbano" if id_parroquia=="130901"
    return "Urbano" if id_parroquia=="130902"
    return "Urbano" if id_parroquia=="130903"
    return "Urbano" if id_parroquia=="130904"
    return "Urbano" if id_parroquia=="130905"
    return "Urbano" if id_parroquia=="131301"
    return "Urbano" if id_parroquia=="131302"
    return "Urbano" if id_parroquia=="131401"
    return "Urbano" if id_parroquia=="131402"
    return "Urbano" if id_parroquia=="140201"
    return "Urbano" if id_parroquia=="140202"
    return "Urbano" if id_parroquia=="170101"
    return "Urbano" if id_parroquia=="170102"
    return "Urbano" if id_parroquia=="170103"
    return "Urbano" if id_parroquia=="170104"
    return "Urbano" if id_parroquia=="170105"
    return "Urbano" if id_parroquia=="170106"
    return "Urbano" if id_parroquia=="170107"
    return "Urbano" if id_parroquia=="170108"
    return "Urbano" if id_parroquia=="170109"
    return "Urbano" if id_parroquia=="170110"
    return "Urbano" if id_parroquia=="170111"
    return "Urbano" if id_parroquia=="170112"
    return "Urbano" if id_parroquia=="170113"
    return "Urbano" if id_parroquia=="170114"
    return "Urbano" if id_parroquia=="170115"
    return "Urbano" if id_parroquia=="170116"
    return "Urbano" if id_parroquia=="170117"
    return "Urbano" if id_parroquia=="170118"
    return "Urbano" if id_parroquia=="170119"
    return "Urbano" if id_parroquia=="170120"
    return "Urbano" if id_parroquia=="170121"
    return "Urbano" if id_parroquia=="170122"
    return "Urbano" if id_parroquia=="170123"
    return "Urbano" if id_parroquia=="170124"
    return "Urbano" if id_parroquia=="170125"
    return "Urbano" if id_parroquia=="170126"
    return "Urbano" if id_parroquia=="170127"
    return "Urbano" if id_parroquia=="170128"
    return "Urbano" if id_parroquia=="170129"
    return "Urbano" if id_parroquia=="170130"
    return "Urbano" if id_parroquia=="170131"
    return "Urbano" if id_parroquia=="170132"
    return "Urbano" if id_parroquia=="170202"
    return "Urbano" if id_parroquia=="170203"
    return "Urbano" if id_parroquia=="170501"
    return "Urbano" if id_parroquia=="170502"
    return "Urbano" if id_parroquia=="170503"
    return "Urbano" if id_parroquia=="180101"
    return "Urbano" if id_parroquia=="180102"
    return "Urbano" if id_parroquia=="180103"
    return "Urbano" if id_parroquia=="180104"
    return "Urbano" if id_parroquia=="180105"
    return "Urbano" if id_parroquia=="180106"
    return "Urbano" if id_parroquia=="180107"
    return "Urbano" if id_parroquia=="180108"
    return "Urbano" if id_parroquia=="180109"
    return "Urbano" if id_parroquia=="180701"
    return "Urbano" if id_parroquia=="180702"
    return "Urbano" if id_parroquia=="180801"
    return "Urbano" if id_parroquia=="180802"
    return "Urbano" if id_parroquia=="190101"
    return "Urbano" if id_parroquia=="190102"
    return "Urbano" if id_parroquia=="230101"
    return "Urbano" if id_parroquia=="230102"
    return "Urbano" if id_parroquia=="230103"
    return "Urbano" if id_parroquia=="230104"
    return "Urbano" if id_parroquia=="230105"
    return "Urbano" if id_parroquia=="230106"
    return "Urbano" if id_parroquia=="230107"
    return "Urbano" if id_parroquia=="240101"
    return "Urbano" if id_parroquia=="240102"
    return "Urbano" if id_parroquia=="240301"
    return "Urbano" if id_parroquia=="240302"
    return "Urbano" if id_parroquia=="240303"
    return "Urbano" if id_parroquia=="240304"
  end

end
