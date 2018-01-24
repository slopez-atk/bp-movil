class OracledbAgencias < ApplicationRecord
  establish_connection "#{Rails.env}_sec".to_sym

  def self.obtener_indicadores_financieros fecha
    data = [
      {
        nro_cuenta: 1,
        valor: "1000000.234"
      },
      {
        nro_cuenta: 11,
        valor: "34523.645"
      },
      {
        nro_cuenta: 1101,
        valor: "300.100"
      },
      {
          nro_cuenta: 1103,
          valor: "200.400"
      },
      {
          nro_cuenta: 14,
          valor: "2000.234"
      },
      {
          nro_cuenta: 1499,
          valor: "1000.234"
      },
      {
          nro_cuenta: 1404,
          valor: "1000.234"
      },
      {
          nro_cuenta: 1428,
          valor: "1000.234"
      },
      {
          nro_cuenta: 1452,
          valor: "1000.00"
      },
      {
          nro_cuenta: 1425,
          valor: "1000.00"
      },
      {
          nro_cuenta: 1426,
          valor: "1000.00"
      },
      {
          nro_cuenta: 1427,
          valor: "1000.00"
      },
      {
          nro_cuenta: 1449,
          valor: "1000.00"
      },
      {
          nro_cuenta: 1450,
          valor: "1000.00"
      },
      {
          nro_cuenta: 1451,
          valor: "1000.00"
      },
      {
          nro_cuenta: 2,
          valor: "500000.234"
      },
      {
          nro_cuenta: 21,
          valor: "1000.234"
      },
      {
          nro_cuenta: 2101,
          valor: "200.00"
      },
      {
          nro_cuenta: 2103,
          valor: "300.00"
      },
      {
          nro_cuenta: 31,
          valor: "1000.234"
      },
      {
          nro_cuenta: 5,
          valor: "200.00"
      },
      {
          nro_cuenta: 51,
          valor: "300.00"
      },
      {
          nro_cuenta: 5102,
          valor: "200.00"
      },
      {
          nro_cuenta: 5103,
          valor: "300.00"
      },
      {
          nro_cuenta: 5104,
          valor: "1000.234"
      },
      {
          nro_cuenta: 54,
          valor: "200.00"
      },
      {
          nro_cuenta: 56,
          valor: "300.00"
      },
      {
          nro_cuenta: 4,
          valor: "200.00"
      },
      {
          nro_cuenta: 41,
          valor: "300.00"
      },
      {
          nro_cuenta: 44,
          valor: "1000.234"
      },
      {
          nro_cuenta: 45,
          valor: "200.00"
      },
      {
          nro_cuenta: 4101,
          valor: "300.00"
      },
      {
          nro_cuenta: 4501,
          valor: "300.00"
      }
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
end