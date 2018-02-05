class DesempenioSocialController < ApplicationController
  before_action :authenticate_user!

  def index

  end


  def balance_social
    fecha_inicial = params["fecha_inicial"].to_date.strftime('%d-%m-%Y')
    fecha_final = params["fecha_final"].to_date.strftime('%d-%m-%Y')
    agencia = params["agencia"]
    @mes_1 = fecha_inicial.to_date.strftime('%B')
    @mes_2 = fecha_final.to_date.strftime('%B')

    if agencia == "todos"
      method = OracledbAgencias.method(:obtener_sumatoria_cuentas_cacmu)
    else
      method = OracledbAgencias.method(:obtener_sumatoria_cuentas)
    end


    # Cuentas que voy a iterar
    cuentas_1 = [5104, [5102,5103], 560105, 5690, 2101, 2103, 2606, [2603,2607]]
    nombres_1 = ["Intereses por créditos otorgados (ingresos ganados)", "Intereses por ahorros & inversiones",
                "Ingresos por venta de activos", "Ingresos no operacionales", "Captación de ahorros",
                "Captación DPF", "Financiamiento local", "Financiamiento internacional"]

    @valor_directo = []
    total_valor_directo_1 = 0
    total_valor_directo_2 = 0

    # Valor económico directo creado
    cuentas_1.each_with_index do |cuenta, index|
      if cuenta.kind_of?(Array)
        sumatoria_valor_1 = 0
        sumatoria_valor_2 = 0
        cuenta.each do |nro_cuenta|
          sumatoria_valor_1 += method.call nro_cuenta, fecha_inicial, agencia, "true"
          sumatoria_valor_2 += method.call nro_cuenta, fecha_final, agencia, "true"
        end
        temp = {cuenta: nombres_1[index], valor_1: sumatoria_valor_1, porcentaje_1: 0, valor_2: sumatoria_valor_2, porcentaje_2: 0, tasa_variacion: 0, variacion: 0}
        total_valor_directo_1 += sumatoria_valor_1
        total_valor_directo_2 += sumatoria_valor_2
        @valor_directo.push(temp)
      else
        valor_1 = method.call cuenta, fecha_inicial, agencia, "true"
        valor_2 = method.call cuenta, fecha_final, agencia, "true"
        temp = {cuenta: nombres_1[index], valor_1: valor_1, porcentaje_1: 0, valor_2: valor_2, porcentaje_2: 0, tasa_variacion: 0, variacion: 0}
        total_valor_directo_1 += valor_1
        total_valor_directo_2 += valor_2
        @valor_directo.push(temp)
      end
    end
    # Calcular porcentajes total y variaciones
    @valor_directo.each do |row|
      row.stringify_keys!
      row["porcentaje_1"] = ((row["valor_1"].to_f * 100)/total_valor_directo_1).to_f.round(2)
      row["porcentaje_2"] = ((row["valor_2"].to_f * 100)/total_valor_directo_2).to_f.round(2)

      # tasa de variacion
      row["tasa_variacion"] = (((row["valor_2"] - row["valor_1"]) / row["valor_1"])*100).to_f.round(2) unless row["valor_1"] == 0
      # variacion
      row["variacion"] = (row["valor_2"] - row["valor_1"]).to_f.round(2)

    end
    temp2 = total_valor_directo_2 - total_valor_directo_1
    @valor_directo.push({cuenta: "Total valor económico directo creado", valor_1: total_valor_directo_1, porcentaje_1: "100", valor_2: total_valor_directo_2, porcentaje_2: "100%", tasa_variacion: 0, variacion: temp2})





    # Valor económico distribuido
    cuentas_2 = [4101,2590, 2506, 4504, [4501,4502], [45, -4501, -4502, -45079005],45079005]
    nombres_2 = ["Pago interes a socios por ahorros & inversiones neto", "Pago a acreedores locales (k+i)",
                "Pago a proveedores", "Pago a Estado", "Pago talento humano", "Operación del negocio/gastos de operación",
                "Inversión en la comunidad"]
    @valor_distribuido = []
    total_valor_distribuido_1 = 0
    total_valor_distribuido_2 = 0

    cuentas_2.each_with_index do |cuenta, index|
      if cuenta.kind_of?(Array)
        sumatoria_valor_1 = 0
        sumatoria_valor_2 = 0
        cuenta.each do |nro_cuenta|

          if nro_cuenta < 0
            cuenta_positiva = nro_cuenta * -1
            sumatoria_valor_1 -= method.call cuenta_positiva, fecha_inicial, agencia, "true"
            sumatoria_valor_2 -= method.call cuenta_positiva, fecha_final, agencia, "true"
          else
            sumatoria_valor_1 += method.call nro_cuenta, fecha_inicial, agencia, "true"
            sumatoria_valor_2 += method.call nro_cuenta, fecha_final, agencia, "true"
          end

        end
        temp = {cuenta: nombres_2[index], valor_1: sumatoria_valor_1, porcentaje_1: 0, valor_2: sumatoria_valor_2, porcentaje_2: 0, tasa_variacion: 0, variacion: 0}
        total_valor_distribuido_1 += sumatoria_valor_1
        total_valor_distribuido_2 += sumatoria_valor_2
        @valor_distribuido.push(temp)
      else
        valor_1 = method.call cuenta, fecha_inicial, agencia, "true"
        valor_2 = method.call cuenta, fecha_final, agencia, "true"
        temp = {cuenta: nombres_2[index], valor_1: valor_1, porcentaje_1: 0, valor_2: valor_2, porcentaje_2: 0, tasa_variacion: 0, variacion: 0}
        total_valor_distribuido_1 += valor_1
        total_valor_distribuido_2 += valor_2
        @valor_distribuido.push(temp)
      end
    end
    # Calcular porcentajes y total y variacion
    @valor_distribuido.each do |row|
      row.stringify_keys!
      row["porcentaje_1"] = ((row["valor_1"].to_f * 100)/total_valor_distribuido_1).to_f.round(2)
      row["porcentaje_2"] = ((row["valor_2"].to_f * 100)/total_valor_distribuido_2).to_f.round(2)

      # tasa variacion
      row["tasa_variacion"] = (((row["valor_2"] - row["valor_1"]) / row["valor_1"])*100).to_f.round(2) unless row["valor_1"] == 0
      #variacion
      row["variacion"] = (row["valor_2"] - row["valor_1"]).to_f.round(2)

    end
    temp2 = total_valor_distribuido_2 - total_valor_distribuido_1
    @valor_distribuido.push({cuenta: "Total valor económico distribuido", valor_1: total_valor_distribuido_1, porcentaje_1: "100", valor_2: total_valor_distribuido_2, porcentaje_2: "100%", tasa_variacion: 0, variacion: temp2})

    @total = [((total_valor_distribuido_1.to_f/total_valor_directo_1.to_f).to_f * 100.00).to_f.round(2), ((total_valor_distribuido_2.to_f/total_valor_directo_2.to_f).to_f * 100.00).to_f.round(2)]

  end

  def set_layout
    return "desempenio_social"
    super
  end
end