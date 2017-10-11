class Oracledb < ApplicationRecord
  establish_connection "#{Rails.env}_sec".to_sym

  def self.getCreditosInmobiliarios
    # results = connection.exec_query("Select * from inmobiliario")
    results = connection.exec_query("select
    t.numero_operacion AS ID_CREDITO,
    t.codcl AS ID_SOCIO,
    (select s.mcli_apellido_pat||' '||s.mcli_apellido_mat||' '||s.mcli_nombres from socios s where s.codigo_socio=c.codigo_socio)as NOMBRES,
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
          ,(SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = c.codigo_grupo) AS  TIPO_CREDITO
    from temp_c02 t, cred_creditos c
    where t.dias_morocidad>=271 and c.codigo_grupo in (3)
    and c.numero_credito=t.numero_operacion")
    if results.present?
      return results
    else
      return nil
    end
  end

  def self.getCreditosConsumo
    # results = connection.exec_query("Select * from consumo")
    results = connection.exec_query("select
    t.codcl id_socio,
    t.numero_operacion,
    (select s.mcli_apellido_pat||' '||s.mcli_apellido_mat||' '||s.mcli_nombres from socios s where s.codigo_socio=c.codigo_socio)as nombres,
    t.identificacion CEDULA,
    (select max(mcli_telefonos) from socios_direcciones where codigo_socio=c.codigo_socio )telefono,
    (select max(mcli_telefono_celular) from socios_direcciones where codigo_socio=c.codigo_socio )celular,
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
    and c.codigo_socio=s.codigo_socio) grupo_organizado,
    (select descripcion from sifv_sucursales where codigo_sucursal=c.codigo_sucursal)sucursal,
    (select usu_nombres||' '||usu_apellidos from sifv_usuarios_sistema where codigo_usuario=c.oficre) oficial_credito,
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
             )cartera_heredada,
    (select min(j.fecinical) from cred_tabla_amortiza_variable j
    where j.ordencal = (select min(i.ordencal)  from cred_tabla_amortiza_variable i
                        where i.numero_credito = c.NUMERO_CREDITO)
      and j.numero_credito = c.NUMERO_CREDITO) as FECHA_CONCESION,
    (select max(j.fecfincal) from cred_tabla_amortiza_variable j
    where j.ordencal = (select max(i.ordencal)  from cred_tabla_amortiza_variable i
                        where i.numero_credito = c.NUMERO_CREDITO)
      and j.numero_credito = c.NUMERO_CREDITO) as FECHA_VENCIMIENTO,
    c.monto_real,
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
            (SELECT TRIM(NUMERO_ID) FROM SOCIOS_GARANTIAS_FIDUCIARIAS  where codigo_socio=c.codigo_socio and numero_credito=c.numero_credito and num_registro=2))  as dir_garante,
    (SELECT gara_telefonos
    FROM SOCIOS_GARANTES_DIRECCIONES WHERE CODIGO_SOCIO=c.CODIGO_SOCIO AND NUM_REGISTRO=(select max(num_registro)
    from SOCIOS_GARANTES_DIRECCIONES where codigo_socio=c.codigo_socio) and rownum=1
           AND TRIM(NUMERO_ID_GARANTE) IN
            (SELECT TRIM(NUMERO_ID) FROM SOCIOS_GARANTIAS_FIDUCIARIAS  where codigo_socio=c.codigo_socio and numero_credito=c.numero_credito and num_registro=2))  as telf_garante,
    t.calificacion_propia CALIFICACION_PROPIA,
    t.valor_cartera_castigada VALOR_CARTERA_CASTIGADA,
    (case when (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('TERRENOS','CASAS','VEHICULOS'))=0 then 'NO'
          when (select max(valor) from cred_ctas_contables_temp_x_usu where codigo_socio=c.codigo_socio and descripcion in ('TERRENOS','CASAS','VEHICULOS'))is null then 'NO'
          ELSE 'SI' end
    --select * from cred_ctas_contables_temp_x_usu where codigo_socio=11299
    )bienes,
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
          else 'NO DISPONE' end)bien,
    (SELECT MIN(DESCRIPCION_GRUPO) FROM CRED_GRUPO_SEGMENTOS_CREDITO G WHERE G.CODIGO_GRUPO = c.codigo_grupo) AS  TIPO_CREDITO
    from temp_c02 t, cred_creditos c
    where t.dias_morocidad>=96 and c.codigo_grupo in (4,2)
    and c.numero_credito=t.numero_operacion
    ")
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


end
