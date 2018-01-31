class OracledbAgencias < ApplicationRecord
  establish_connection "#{Rails.env}_sec".to_sym

  def self.obtener_indicadores_financieros fecha
    cuentas = [1, 11, 1101, 1103, 14, 1499, 1404, 1428, 1452, 1425, 1426, 1427 , 1449, 1450,
             1451, 2, 21, 2101, 2103, 31, 5, 51, 5102, 5103, 5104, 54, 56, 4, 41, 44, 45, 4101,
            4501, 14250505, 14260505, 14270505, 14280505, 14490505, 14500505, 14510505, 14520505, 14251005,
             14251505, 14252005, 14261005, 14261505, 14262005, 14262505, 14271005, 14271505, 14272005,
             14272505, 14281005, 14281505, 14282005, 14282505, 14491005, 14492505, 14501005, 14501505,
             14502005, 14502505, 14511005, 14511505, 14512005, 14512505, 14513005, 14521005,
             14521505, 14522005, 14522505]

    data = []
    cuentas.each do |cuenta|
      valor = OracledbAgencias.obtener_sumatoria_cuentas cuenta, fecha
      a = {nro_cuenta: cuenta, valor: valor}
      data.push(a)
    end
    return data
    data = [
      {nro_cuenta: 1, valor: "1000000.234"},
      {nro_cuenta: 11,valor: "34523.645"},
      {nro_cuenta: 1101,valor: "300.100"},
      {nro_cuenta: 1103, valor: "200.400"},
      {nro_cuenta: 14,valor: "2000.234"},
      {nro_cuenta: 1499,valor: "1000.234"},
      {nro_cuenta: 1404,valor: "1000.234"},
      {nro_cuenta: 1428, valor: "1000.234"},
      {nro_cuenta: 1452,valor: "1000.00"},
      {nro_cuenta: 1425,valor: "1000.00"},
      {nro_cuenta: 1426,valor: "1000.00"},
      {nro_cuenta: 1427,valor: "1000.00"},
      {nro_cuenta: 1449, valor: "1000.00"},
      {nro_cuenta: 1450, valor: "1000.00"},
      {nro_cuenta: 1451, valor: "1000.00"},
      {nro_cuenta: 2, valor: "500000.234"},
      {nro_cuenta: 21, valor: "1000.234"},
      {nro_cuenta: 2101, valor: "200.00"},
      {nro_cuenta: 2103, valor: "300.00"},
      {nro_cuenta: 31, valor: "1000.234"},
      {nro_cuenta: 5, valor: "200.00"},
      {nro_cuenta: 51, valor: "300.00"},
      {nro_cuenta: 5102, valor: "200.00"},
      {nro_cuenta: 5103, valor: "300.00"},
      {nro_cuenta: 5104, valor: "1000.234"},
      {nro_cuenta: 54, valor: "200.00"},
      {nro_cuenta: 56, valor: "300.00"},
      {nro_cuenta: 4, valor: "200.00"},
      {nro_cuenta: 41, valor: "300.00"},
      {nro_cuenta: 44, valor: "1000.234"},
      {nro_cuenta: 45, valor: "200.00"},
      {nro_cuenta: 4101, valor: "300.00"},
      {nro_cuenta: 4501, valor: "300.00"}
    ]
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

  def self.obtener_sumatoria_cuentas cuenta, fecha
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
    AND D.CODIGO_SUCURSAL=1
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


    return sumatoria;
  end
end