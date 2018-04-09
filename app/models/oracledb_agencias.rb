class OracledbAgencias < ApplicationRecord
  establish_connection "#{Rails.env}_sec".to_sym

  def self.obtener_indicadores_financieros fecha, agencia
    cuentas = [1, 11, 1101, 1103, 14, 1499, 1404, 1428, 1452, 1425, 1426, 1427 , 1449, 1450,
             1451, 2, 21, 2101, 2103, 31, 5, 51, 5102, 5103, 5104, 54, 56, 4, 41, 44, 45, 4101,
            4501, 14250505, 14260505, 14270505, 14280505, 14490505, 14500505, 14510505, 14520505, 14251005,
             14251505, 14252005, 14261005, 14261505, 14262005, 14262505, 14271005, 14271505, 14272005,
             14272505, 14281005, 14281505, 14282005, 14282505, 14491005, 14492505, 14501005, 14501505,
             14502005, 14502505, 14511005, 14511505, 14512005, 14512505, 14513005, 14521005,
             14521505, 14522005, 14522505]

    data = []
    cuentas.each do |cuenta|
      if agencia == 'todos'
        valor = OracledbAgencias.obtener_sumatoria_cuentas_cacmu cuenta, fecha
      else
        valor = OracledbAgencias.obtener_sumatoria_cuentas cuenta, fecha, agencia
      end
      a = {nro_cuenta: cuenta, valor: valor}
      data.push(a)
    end
    return data
  end



  def self.obtener_cuentas_enceradas
    return data = [
      {nro_cuenta: 1, valor: "0"},
      {nro_cuenta: 11,valor: "0"},
      {nro_cuenta: 1101,valor: "0"},
      {nro_cuenta: 1103,valor: "0"},
      {nro_cuenta: 14,valor: "0"},
      {nro_cuenta: 1499, valor: "0"},
      {nro_cuenta: 1404, valor: "0"},
      {nro_cuenta: 1428,valor: "0"},
      {nro_cuenta: 1452,valor: "0"},
      {nro_cuenta: 1425,valor: "0"},
      {nro_cuenta: 1426,valor: "0"},
      {nro_cuenta: 1427,valor: "0"},
      {nro_cuenta: 1449,valor: "0"},
      {nro_cuenta: 1450,valor: "0"},
      {nro_cuenta: 1451,valor: "0"},
      {nro_cuenta: 2,valor: "0"},
      {nro_cuenta: 21,valor: "0"},
      {nro_cuenta: 2101,valor: "0"},
      {nro_cuenta: 2103,valor: "0"},
      {nro_cuenta: 31,valor: "0"},
      {nro_cuenta: 5,valor: "0"},
      {nro_cuenta: 51,valor: "0"},
      {nro_cuenta: 5102,valor: "0"},
      {nro_cuenta: 5103,valor: "0"},
      {nro_cuenta: 5104,valor: "0"},
      {nro_cuenta: 54,valor: "0"},
      {nro_cuenta: 56,valor: "0"},
      {nro_cuenta: 4,valor: "0"},
      {nro_cuenta: 41,valor: "0"},
      {nro_cuenta: 44,valor: "0"},
      {nro_cuenta: 45,valor: "0"},
      {nro_cuenta: 4101,valor: "0"},
      {nro_cuenta: 4501,valor: "0"}
    ]
  end




  def self.obtener_sumatoria_cuentas cuenta, fecha, agencia, balance = "false", seps = "false"
    # if cuenta.to_i == 14
    #   return 2
    # elsif cuenta.to_i == 51
    #   return 10
    # elsif cuenta.to_i == 260605
    #   return 257876.9
    # elsif cuenta.to_i == 260610
    #   return 224328.55
    # else
    #   return 1
    # end

    results = connection.exec_query("
    SELECT CODIGO_SUCURSAL,
    --(select max(descripcion) from sifv_sucursales ss where ss.codigo_sucursal=codigo_sucursal)sucursal,
    CUE_CODIGO,max(NOMBRE_CUENTA) CUENTA,SUM(DEBITO)-SUM(CREDITO) AS SALDO FROM (
    SELECT D.CODIGO_SUCURSAL,D.CUE_CODIGO,C.COM_FECHA,D.COM_CONCEPTO,
    DECODE(D.COM_CRE_DEB,'D',COM_VALOR,0) DEBITO,
    DECODE(D.COM_CRE_DEB,'C',COM_VALOR,0) CREDITO,
    C.COM_NUMERO,
    (SELECT CUE_DESCRIPCION FROM CON_PLAN P
    WHERE P.CODIGO_EMPRESA=1 AND P.CODIGO_SUCURSAL=18 AND P.PER_CODIGO= 2017 AND P.CUE_CODIGO = D.CUE_CODIGO) NOMBRE_CUENTA
    FROM CON_DETALLE_COMPROBANTES D,CON_CABECERA_COMPROBANTES C
    WHERE D.COM_NUMERO=C.COM_NUMERO
    AND D.CODIGO_EMPRESA=C.CODIGO_EMPRESA
    AND D.PER_CODIGO=C.PER_CODIGO
    AND D.CODIGO_SUCURSAL=C.CODIGO_SUCURSAL
    AND D.CODIGO_SUCURSAL=#{agencia.to_i}
    --AND D.CODIGO_SUCURSAL<=18
    AND D.CUE_CODIGO like '#{cuenta.to_i}%'
    --AND D.CUE_CODIGO like '1101'
    --select * from temp_b11
    AND C.COM_ESTADO='M'
    --AND TRUNC(C.COM_FECHA)>=TO_DATE('01/12/2017','DD/MM/YYYY')
    AND TRUNC(C.COM_FECHA)<=TO_DATE('#{fecha.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
    AND C.PER_CODIGO = #{fecha.to_date.year}
    ORDER BY D.CODIGO_SUCURSAL,D.CUE_CODIGO,C.COM_FECHA,C.COM_NUMERO )
    GROUP BY CODIGO_SUCURSAL,CUE_CODIGO
    ORDER BY CODIGO_SUCURSAL
    --select * from CON_PLAN where per_codigo=2018
    --select (cue_codigo) from con_detalle_comprobantes cd where cue_codigo like ('%1%')
    ")

    sumatoria = 0
    results.each do |row|
      sumatoria += row["saldo"]
    end
    if seps == "true"
      if cuenta.to_s[0] == '2' || cuenta.to_s[0] == '3' || cuenta.to_s[0] == '5'
        return sumatoria.to_f * -1
      end
    end
    if balance == "true"
      if  cuenta.to_i == 2101 || cuenta.to_i == 2103 || cuenta.to_i == 2606 || cuenta.to_i == 2603 || cuenta.to_i == 2607 || cuenta.to_i == 2590 || cuenta.to_i == 2506 || cuenta.to_i == 5104 || cuenta.to_i == 5102 || cuenta.to_i == 5103 || cuenta.to_i == 560105 || cuenta.to_i == 5690
        return (sumatoria * -1)
      end
    end
    return sumatoria.to_f
  end




  # Saca la sumatoria de cuentas de toda la cooperativa
  def self.obtener_sumatoria_cuentas_cacmu cuenta, fecha, agencia = 0, balance = "false", seps = "false"
    # if cuenta.to_i == 14
    #   return 20
    # elsif cuenta.to_i == 51
    #   return 15
    # elsif cuenta.to_i == 260605
    #   return 6344453.9
    # elsif cuenta.to_i == 260610
    #   return 7348234.55
    # else
    #   return 2
    # end
    results = connection.exec_query("
    SELECT CODIGO_SUCURSAL,
    --(select max(descripcion) from sifv_sucursales ss where ss.codigo_sucursal=codigo_sucursal)sucursal,
    CUE_CODIGO,max(NOMBRE_CUENTA) CUENTA,SUM(DEBITO)-SUM(CREDITO) AS SALDO FROM (
    SELECT D.CODIGO_SUCURSAL,D.CUE_CODIGO,C.COM_FECHA,D.COM_CONCEPTO,
    DECODE(D.COM_CRE_DEB,'D',COM_VALOR,0) DEBITO,
    DECODE(D.COM_CRE_DEB,'C',COM_VALOR,0) CREDITO,
    C.COM_NUMERO,
    (SELECT CUE_DESCRIPCION FROM CON_PLAN P
    WHERE P.CODIGO_EMPRESA=1 AND P.CODIGO_SUCURSAL=18 AND P.PER_CODIGO= 2017 AND P.CUE_CODIGO = D.CUE_CODIGO) NOMBRE_CUENTA
    FROM CON_DETALLE_COMPROBANTES D,CON_CABECERA_COMPROBANTES C
    WHERE D.COM_NUMERO=C.COM_NUMERO
    AND D.CODIGO_EMPRESA=C.CODIGO_EMPRESA
    AND D.PER_CODIGO=C.PER_CODIGO
    AND D.CODIGO_SUCURSAL=C.CODIGO_SUCURSAL
    AND D.CODIGO_SUCURSAL>=1
    AND D.CODIGO_SUCURSAL<=18
    AND D.CUE_CODIGO like '#{cuenta.to_i}%'
    AND C.COM_ESTADO='M'
    and d.cue_codigo not in ('29080501','29080502','29080503','29080505','29080506','29080507','29080508','29080509','29080518', '19080501','19080502','19080503','19080505','19080506','19080507','19080508','19080509','19080518')
    AND TRUNC(C.COM_FECHA)<=TO_DATE('#{fecha.to_date.strftime('%d-%m-%Y')}','DD/MM/YYYY')
    AND C.PER_CODIGO = #{fecha.to_date.year}
    ORDER BY D.CODIGO_SUCURSAL,D.CUE_CODIGO,C.COM_FECHA,C.COM_NUMERO )
    GROUP BY CODIGO_SUCURSAL,CUE_CODIGO
    ORDER BY CODIGO_SUCURSAL
    ")

    sumatoria = 0
    results.each do |row|
      sumatoria += row["saldo"]
    end
    if balance == "true"
      if cuenta.to_i == 2101 || cuenta.to_i == 2103 || cuenta.to_i == 2606 || cuenta.to_i == 2603 || cuenta.to_i == 2607 || cuenta.to_i == 2590 || cuenta.to_i == 2506 || cuenta.to_i == 5104 || cuenta.to_i == 5102 || cuenta.to_i == 5103 || cuenta.to_i == 560105 || cuenta.to_i == 5690
        return (sumatoria * -1)
      end
    end
    if seps == "true"
      if cuenta.to_s[0] == '2' || cuenta.to_s[0] == '3' || cuenta.to_s[0] == '5'
        return sumatoria.to_f * -1
      end
    end
    sumatoria.to_f
  end



  def self.obtener_indicador_seps array_cuentas, fecha, agencia
    valor = 0.0
    array_cuentas.each do |cuenta|
      if agencia == 'todos'
        if cuenta > 0
          valor += (OracledbAgencias.obtener_sumatoria_cuentas_cacmu cuenta, fecha, 0, "false", "true").round(2)
        else
          cuenta_positiva = cuenta * -1
          valor -= (OracledbAgencias.obtener_sumatoria_cuentas_cacmu cuenta_positiva, fecha, 0, "false", "true").round(2)
        end


      else
        if cuenta > 0
          valor += (OracledbAgencias.obtener_sumatoria_cuentas cuenta, fecha, agencia, "false", 'true').round(2)
        else
          cuenta_positiva = cuenta * -1
          valor -= (OracledbAgencias.obtener_sumatoria_cuentas cuenta_positiva, fecha, agencia, "false", 'true').round(2)
        end

      end
      valor = valor.round(2)
    end
    valor
  end


  def self.obtener_indicador_seps_guardados agencia
    filename =  "#{agencia}.txt"
    data = Marshal.load File.read(Rails.public_path.join("indicadores",filename))
    return data
  end



  def self.guardar_indicadores_seps

    [1,5,3,1,7,9,8,6,'todos'].each do |agencia|
      fecha_final = (Time.now - 1.month).end_of_month
      fecha_inicial = fecha_final.last_year.end_of_year
      arrego_de_fechas = OracledbAgencias.extraer_fechas_entre(fecha_inicial, fecha_final)

      solvencia_normativa = Array.new
      apalancamiento = Array.new
      liquidez = Array.new
      morosidad_ampliada = Array.new
      covertura_provision = Array.new
      relacion_productividad = Array.new
      roa = Array.new
      eficiencia_institucional = Array.new
      grado_absorcion_mf = Array.new
      tasa_activa = Array.new
      tasa_pasiva_general = Array.new
      roe = Array.new

      arrego_de_fechas.each do |date|
        data = OracledbAgencias.indicadores_seps_al_mes date, agencia
        solvencia_normativa.push(data[0])
        apalancamiento.push(data[1])
        liquidez.push(data[2])
        morosidad_ampliada.push(data[3])
        covertura_provision.push(data[4])
        relacion_productividad.push(data[5])
        roa.push(data[6])
        eficiencia_institucional.push(data[7])
        grado_absorcion_mf.push(data[8])
        tasa_activa.push(data[9])
        tasa_pasiva_general.push(data[10])
        roe.push(data[11])
      end

      indicadores = [solvencia_normativa, apalancamiento, liquidez,
                     morosidad_ampliada, covertura_provision, relacion_productividad,
                     roa, eficiencia_institucional, grado_absorcion_mf, tasa_activa,
                     tasa_pasiva_general, roe]

      filename =  "#{agencia}.txt"
      file = File.open(Rails.public_path.join("indicadores",filename), "wb")
      serialized_array = Marshal.dump(indicadores)
      File.open(file, "wb"){ |f| f << serialized_array }
    end
  end

  def self.indicadores_seps_al_mes date, agencia

    fecha = ''
    if date.to_date.month == Time.now.month and date.to_date.year == Time.now.year
      fecha = (Time.now.strftime("%d/%m/%Y").to_date - 1.day).strftime("%d/%m/%Y")
    else
      fecha = date.to_date.end_of_month.strftime("%d/%m/%Y")
    end

    # ------------------------- Solvencia normativa -----------------------------
    # Patrimonio tecnico constituido primario
    cuentas = [31, 3301, 3302, 3303, 34, 35, 3601, 3602, 3604]
    if fecha.to_date.month == 12
      patrimonio_primario = OracledbAgencias.obtener_indicador_seps cuentas, fecha, agencia
      cta3603 = [3603]
      cta3603 = (OracledbAgencias.obtener_indicador_seps cta3603, fecha, agencia) * 0.5
      patrimonio_primario += cta3603
    else
      patrimonio_primario = OracledbAgencias.obtener_indicador_seps cuentas, fecha, agencia

      cta5 = OracledbAgencias.obtener_indicador_seps [5], fecha, agencia
      cta4 = OracledbAgencias.obtener_indicador_seps [4], fecha, agencia
      patrimonio_primario += (cta5 - cta4) * 0.5
    end



    # Patrimonio tecnico constituido secundario
    cuentas_patrimonio_secundario = [3305, 3310]
    patrimonio_secundario = (OracledbAgencias.obtener_indicador_seps cuentas_patrimonio_secundario, fecha, agencia) * 0.5

    patrimonio = patrimonio_primario + patrimonio_secundario


    # Activo ponderado por riesgos

    # Activo ponderado 0
    cuentas_apr0 = [11, 1302, 1304, 1306, 199005, 190286, 6404, -640410, 7108]
    apr0 = (OracledbAgencias.obtener_indicador_seps cuentas_apr0, fecha, agencia) * 0

    # Activo ponderado 20
    cuentas_apr20 = [12 , 1307]
    apr20 = (OracledbAgencias.obtener_indicador_seps cuentas_apr20, fecha, agencia) * 0.2

    # Activo ponderado 50
    cuentas_apr50 = [1301 ,1303 ,1305 ,1403 ,1408]
    apr50 = (OracledbAgencias.obtener_indicador_seps cuentas_apr50, fecha, agencia) * 0.5

    # Activo ponderado 100
    cta13 = [13]
    cuentas_temp1 = [1301, 1302, 1303, 1304, 1305, 1306, 1307]
    cta14 = [14]
    cuentas_temp2 = [1403, 1408]
    cuentas_temp3 = [16, 17, 18, 19]
    cuentas_temp4 = [199005, 190286]
    cta64 = [64]
    cta6404 = [6404]

    valor_cta13 = OracledbAgencias.obtener_indicador_seps cta13, fecha, agencia
    valor_cuentas_temp1 = OracledbAgencias.obtener_indicador_seps cuentas_temp1, fecha, agencia
    valor_cta14 = OracledbAgencias.obtener_indicador_seps cta14, fecha, agencia
    valor_cuentas_temp2 = OracledbAgencias.obtener_indicador_seps cuentas_temp2, fecha, agencia
    valor_cuentas_temp3 = OracledbAgencias.obtener_indicador_seps cuentas_temp3, fecha, agencia
    valor_cuentas_temp4 = OracledbAgencias.obtener_indicador_seps cuentas_temp4, fecha, agencia
    valor_cta64 = OracledbAgencias.obtener_indicador_seps cta64, fecha, agencia
    valor_cta6404 = OracledbAgencias.obtener_indicador_seps cta6404, fecha, agencia

    apr100 = valor_cta13 - (valor_cuentas_temp1) +
        valor_cta14 - (valor_cuentas_temp2) +
        valor_cuentas_temp3 - (valor_cuentas_temp4) + valor_cta64 - valor_cta6404

    activo_ponderado_riesgos = apr0 + apr20 + apr50 + apr100
    solvencia = (patrimonio / activo_ponderado_riesgos).round(4)

    # ------------------------------------------------------------------------------

    # ---------------------------- Apalancamiento ----------------------------------
    cta2 = [2]
    cta3 = [3]

    valor_cta2 = OracledbAgencias.obtener_indicador_seps cta2, fecha, agencia
    valor_cta3 = OracledbAgencias.obtener_indicador_seps cta3, fecha, agencia

    apalancamiento = (valor_cta2 / valor_cta3).round(4)
    # ------------------------------------------------------------------------------


    # ---------------------------- Liquidez ----------------------------------------
    # Activos liquidos
    cuentas_fond_dis_net = [11, -1105]
    cuentas_oper_inter = [1201, 2201]
    cuentas_oper_invers = [1202, 130705, -2102, -2202]
    cuentas_inver_liquidas = [130105,130110,130150,
                              130155,130205,130210,130305,
                              130310,130350,130355,130405,
                              130410,130115,130160,130215,
                              130315,130360,130415,130505,
                              130510,130515,130550,130555,
                              130560,130605,130610,130615]
    valor_fond_dis_net = OracledbAgencias.obtener_indicador_seps cuentas_fond_dis_net, fecha, agencia
    valor_oper_inter = OracledbAgencias.obtener_indicador_seps cuentas_oper_inter, fecha, agencia
    valor_oper_invers = OracledbAgencias.obtener_indicador_seps cuentas_oper_invers, fecha, agencia
    valor_inver_liquidas = OracledbAgencias.obtener_indicador_seps cuentas_inver_liquidas, fecha, agencia

    activos_liquidos = valor_fond_dis_net + valor_oper_inter + valor_oper_invers + valor_inver_liquidas

    # Pasivos Exigibles
    cta_pasivos_ex_1 = [2101,210305,210310,
                        2105,23,24,2601,260205,
                        260210,260250,260255,
                        260305,260310,260405,
                        260410,260450,260455,
                        260605,260610,260705,
                        260710,269005,269010,
                        27,2903]
    pasivos_ex_1 = OracledbAgencias.obtener_indicador_seps cta_pasivos_ex_1, fecha, agencia


    cta_pasivos_ex_2 = [2103, -210305, -210310]
    pasivos_ex_2 = OracledbAgencias.obtener_indicador_seps cta_pasivos_ex_2, fecha, agencia

    cta_pasivos_ex_3 = [2104]
    pasivos_ex_3 = OracledbAgencias.obtener_indicador_seps cta_pasivos_ex_3, fecha, agencia

    cta_pasivos_ex_4 = [26,-2601,-260205,-260210,
                        -260250,-260255,-260305,
                        -260310,-260405,-260410,
                        -260450,-260455,-260605,
                        -260610,-260705,-260710,
                        -269005,-269010]
    pasivos_ex_4 = OracledbAgencias.obtener_indicador_seps cta_pasivos_ex_4, fecha, agencia

    pasivos_exegibles = pasivos_ex_1 + pasivos_ex_2 + pasivos_ex_3 + pasivos_ex_4
    liquidez = (activos_liquidos / pasivos_exegibles).round(4)
    # ------------------------------------------------------------------------------

    # ---------------------------- Morosidad Ampliada ------------------------------
    cts_cartera_no_devenga = [1425,1426,1427,
                              1428,1429,1430,
                              1431,1432,1433,
                              1434,1435,1436,
                              1437,1438,1439,
                              1440,1441,1442,
                              1443,1444,1445,
                              1446,1447,1448,
                              1479,1481,1483]

    cts_cartera_vencida = [1449,1450,1451,
                           1452,1453,1454,
                           1455,1456,1457,
                           1458,1459,1460,
                           1461,1462,1463,
                           1464,1465,1466,
                           1467,1468,1469,
                           1470,1471,1472,
                           1485,1487,1489]

    valor_cartera_no_devenga = OracledbAgencias.obtener_indicador_seps cts_cartera_no_devenga, fecha, agencia
    valor_cartera_vencida = OracledbAgencias.obtener_indicador_seps cts_cartera_vencida, fecha, agencia

    @@cartera_improductiva = valor_cartera_no_devenga + valor_cartera_vencida

    cts_cartera_bruta = [14, -1499]
    @@valor_cartera_bruta = OracledbAgencias.obtener_indicador_seps cts_cartera_bruta, fecha, agencia

    morosidad_ampliada = (@@cartera_improductiva / @@valor_cartera_bruta).round(4)
    # ------------------------------------------------------------------------------


    # ---------------------------- Cobertura de Provision --------------------------
    provision_cartera = OracledbAgencias.obtener_indicador_seps [-1499], fecha, agencia

    covertura_provision = (provision_cartera / @@cartera_improductiva).round(4)
    # ------------------------------------------------------------------------------


    # ---------------------------- Relación de Productividad -----------------------
    cts_activo_productivo = [1401,1402,1403,1404,1405,
                             1406,1407,1408,1409,1410,
                             1411,1412,1413,1414,1415,
                             1416,1417,1418,1419,1420,
                             1421,1422,1423,1424,1473,
                             1475,1477,1103,12,13,15,
                             1901,190205,190210,190220,
                             190240,190280]
    activo_productivo = OracledbAgencias.obtener_indicador_seps cts_activo_productivo, fecha, agencia

    cts_pasivo_costo = [2101,-210150,2102,-210210,
                        2103,-210330,2105,22,2601,
                        2602,2603,2606,2607,2608,
                        2609,2610,2690,27,-2790,28,
                        -2802,2904]
    pasivo_costo = OracledbAgencias.obtener_indicador_seps cts_pasivo_costo, fecha, agencia


    relacion_productividad = (activo_productivo/pasivo_costo).round(4)
    # ------------------------------------------------------------------------------


    # ---------------------------- ROA ---------------------------------------------
    cts = [5, -4]
    valor_cts = OracledbAgencias.obtener_indicador_seps cts, fecha, agencia

    fecha_anterior = (fecha.to_date - 1.month).end_of_month
    cta = [1]
    valor_t = OracledbAgencias.obtener_indicador_seps cta, fecha, agencia
    valor_t1 = OracledbAgencias.obtener_indicador_seps cta, fecha_anterior, agencia
    activo_total_promedio = (valor_t + valor_t1)/2

    roa = (valor_cts / activo_total_promedio).round(5)
    # ------------------------------------------------------------------------------


    # ---------------------------- Eficiencia Institucional en Colocación ----------
    cta_45 = [45]
    @@valor_cta_45 = OracledbAgencias.obtener_indicador_seps cta_45, fecha, agencia

    eficiencia_institucional = (@@valor_cta_45 / @@valor_cartera_bruta).round(4)
    # ------------------------------------------------------------------------------


    # ---------------------------- Grado de Absorción de Margen Financiero Neto ----
    cta_margen_financiero_bruto = [51,52,53,
                                   54,-41,-42,-43]
    valor_margen_fin_bruto = OracledbAgencias.obtener_indicador_seps cta_margen_financiero_bruto, fecha, agencia



    cta_44 = [44]
    valor_cta_44 = OracledbAgencias.obtener_indicador_seps cta_44, fecha, agencia

    valor_margen_fin_neto = valor_margen_fin_bruto - valor_cta_44

    grado_absorcion_mf = (@@valor_cta_45 / valor_margen_fin_neto).round(4)
    # ------------------------------------------------------------------------------


    # ---------------------------- Tasa Activa General -----------------------------
    cts_5 = [510405,510410,510415,
             510420,510421,510430,
             510435]
    valor_ctas_5 = OracledbAgencias.obtener_indicador_seps cts_5, fecha, agencia

    fecha_anterior = (fecha.to_date - 1.month).end_of_month
    cta_14 = OracledbAgencias.obtener_indicador_seps [14], fecha, agencia
    cta_14t = OracledbAgencias.obtener_indicador_seps [14], fecha_anterior, agencia
    cartera_neta_prom = (cta_14 + cta_14t)/2

    tasa_activa = (valor_ctas_5 / cartera_neta_prom).round(4)
    # ------------------------------------------------------------------------------


    # ---------------------------- Tasa Pasiva General -----------------------------
    cts_410 = [410115, 410130]
    valor_cta_410 = OracledbAgencias.obtener_indicador_seps cts_410, fecha, agencia

    fecha_anterior = (fecha.to_date - 1.month).end_of_month
    cta_2101 = OracledbAgencias.obtener_indicador_seps [2101], fecha, agencia
    cta_2101t = OracledbAgencias.obtener_indicador_seps [2101], fecha_anterior, agencia
    deposito_vista_prom = (cta_2101 + cta_2101t) / 2

    cta_2103 = OracledbAgencias.obtener_indicador_seps [2103], fecha, agencia
    cta_2103t = OracledbAgencias.obtener_indicador_seps [2103], fecha_anterior, agencia
    deposito_plazo_fijo_prom = (cta_2103 + cta_2103t) / 2

    deposito_total = deposito_vista_prom + deposito_plazo_fijo_prom

    tasa_pasiva_general = (valor_cta_410 / deposito_total).round(4)
    # ------------------------------------------------------------------------------


    # ---------------------------- Roe ---------------------------------------------
    mes = fecha.to_date.month.to_f
    # Ingresos promedio
    ingresos_promedio = (OracledbAgencias.obtener_indicador_seps [5], fecha, agencia) / mes * 12.0

    # Egresos promedio
    egresos_promedio = (OracledbAgencias.obtener_indicador_seps [4], fecha, agencia) / mes * 12.0

    roe = (ingresos_promedio - egresos_promedio)
    # ------------------------------------------------------------------------------

    [solvencia, apalancamiento, liquidez, morosidad_ampliada, covertura_provision, relacion_productividad, roa, eficiencia_institucional, grado_absorcion_mf, tasa_activa, tasa_pasiva_general, solvencia]
  end

  def self.extraer_fechas_entre(inicio, fin)
    arr = Array.new
    (inicio.year..fin.year).each do |y|
      mo_start = (inicio.year == y) ? inicio.month : 1
      mo_end = (fin.year == y) ? fin.month : 12


      (mo_start..mo_end).each do |m|
        fecha = Date.new(y,m,1).strftime('%d-%m-%Y').to_s
        arr.push(fecha)
      end
    end
    arr
  end

  def self.guardar_logs
    texto = "Se corrieron exitosamente todos los procesos a las #{ Time.now}"
    filename =  "#{cron_logger}.txt"
    file = File.open(Rails.public_path.join("logs",filename), "wb")
    serialized_array = Marshal.dump(texto)
    File.open(file, "wb"){ |f| f << serialized_array }
  end

  def self.obtener_nombre_agencia number
    case number.to_i
      when 1
        "Matriz"
      when 5
        "La Merced"
      when 3
        "Cuenca del Lago San Pablo"
      when 2
        "Cuenca del Rio Mira"
      when 7
        "Economia Solidaria"
      when 9
        "Frontera Norte"
      when 8
        "Servimóvil"
      when 6
        "Valle Fertil"
    else
      "Todos"
    end
  end

end
