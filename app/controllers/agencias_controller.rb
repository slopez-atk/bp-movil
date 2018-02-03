class AgenciasController < ApplicationController
  before_action :authenticate_user!
  def index

  end

  def indicadores_financieros
    @array_de_datos = Array.new
    fecha_final = Date.current.end_of_year
    fecha_inicial = fecha_final - 1.year
    arrego_de_fechas = extraer_fechas_entre(fecha_inicial, fecha_final)

    terminar_ciclo = false
    arrego_de_fechas.each do |date|
      if terminar_ciclo == false
        fecha = date.to_date
        if fecha.month == Time.now.month and fecha.year == Time.now.year
          data = OracledbAgencias.obtener_indicadores_financieros (Time.now.strftime("%d/%m/%Y").to_date - 1.day).strftime("%d/%m/%Y"), params["agencia"]
          terminar_ciclo = true
          # puts ("Fecha: " + (Time.now.strftime("%d/%m/%Y").to_date - 1.day).strftime("%d/%m/%Y").to_s)
        else
          data = OracledbAgencias.obtener_indicadores_financieros fecha.end_of_month.strftime("%d/%m/%Y"), params["agencia"]
          # puts ("fecha: " + (fecha.end_of_month.strftime("%d/%m/%Y")).to_s)
        end
        @array_de_datos.push(data)
      else
        data = OracledbAgencias.obtener_cuentas_enceradas
        @array_de_datos.push(data)
      end
    end

    # Activos, Fondos disponibles, Recerva por prestamo,
    # Pasivos, Obligaciones con el publico,
    # Depósitos a la vista, DPF y Cesantia
    # certificados de aportacion, Ingresos totales
    # Intereses y descuentos ganados
    # Operaciones Interfinancieras
    # Intereses en inversiones
    # Intereses y descuentos de cartera de crédito
    # Ingresos por servicios
    # Otros ingresos
    # Gastos Totales
    # Gastos Financieros
    # Intereses Causados
    # Gastos de Provisión
    # Gastos Operacionales
    # Gastos de Personal
    @activos = Array.new
    @fondos = Array.new
    @recerva_prestamo = Array.new
    @pasivos = Array.new
    @obligaciones = Array.new
    @deposito_vista = Array.new
    @dpf = Array.new
    @certificados_aportacion = Array.new
    @ingresos_totales = Array.new
    @intereses_descuentos = Array.new
    @operaciones_interfinancieras = Array.new
    @intereses_inversiones = Array.new
    @intereses_cartera_credito = Array.new
    @ingresos_servicio = Array.new
    @otros_ingresos = Array.new
    @gastos_totales = Array.new
    @gastos_financieros = Array.new
    @intereses_causados = Array.new
    @gastos_provision = Array.new
    @gastos_operacionales = Array.new
    @gastos_personal = Array.new

    @array_de_datos.each do |data|
      data.each_with_index do |cuenta, index|
        cuenta.stringify_keys!
        if cuenta["nro_cuenta"] === 1
          @activos.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 11
          @fondos.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 1499
          @recerva_prestamo.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 2
          @pasivos.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 21
          @obligaciones.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 2101
          @deposito_vista.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 2103
          @dpf.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 31
          @certificados_aportacion.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 5
          @ingresos_totales.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 51
          @intereses_descuentos.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 5102
          @operaciones_interfinancieras.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 5103
          @intereses_inversiones.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 5104
          @intereses_cartera_credito.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 54
          @ingresos_servicio.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 56
          @otros_ingresos.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 4
          @gastos_totales.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 41
          @gastos_financieros.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 4101
          @intereses_causados.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 44
          @gastos_provision.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 45
          @gastos_operacionales.push(cuenta["valor"])
        elsif cuenta["nro_cuenta"] === 4501
          @gastos_personal.push(cuenta["valor"])
        end
      end
    end

    # Carteras compuestas
    suma_caja_bancos = 0.0
    @caja_bancos = Array.new

    suma_cartera_bruta = 0.0
    @cartera_bruta = Array.new

    cartera_bruta_micro = 0.0
    @cartera_bruta_microcredito = Array.new

    suma_cartera_riesgo = 0.0
    @cartera_riesgo = Array.new

    suma_patrimonio = 0.0
    @patrimonio = Array.new

    activo = 0.0
    pasivo = 0.0
    @array_de_datos.each do |data|

      data.each do |cuenta|
        if cuenta["nro_cuenta"] == 1101 || cuenta["nro_cuenta"] == 1103
          suma_caja_bancos += cuenta["valor"].to_f.round(3)
        elsif cuenta["nro_cuenta"] == 14 || cuenta["nro_cuenta"] == 1499
          suma_cartera_bruta += cuenta["valor"].to_f.round(3)
        elsif cuenta["nro_cuenta"] == 1404 || cuenta["nro_cuenta"] == 1428 || cuenta["nro_cuenta"] == 1452
          cartera_bruta_micro += cuenta["valor"].to_f.round(3)
        end

        if cuenta["nro_cuenta"] == 1425 || cuenta["nro_cuenta"] == 1426 || cuenta["nro_cuenta"] == 1427 || cuenta["nro_cuenta"] == 1428 || cuenta["nro_cuenta"] == 1449 || cuenta["nro_cuenta"] == 1450 || cuenta["nro_cuenta"] == 1451 || cuenta["nro_cuenta"] == 1452
          suma_cartera_riesgo += cuenta["valor"].to_f.round(3)
        end

        if cuenta["nro_cuenta"] == 1
          activo = cuenta["valor"].to_f.round(3)
        elsif cuenta["nro_cuenta"] == 2
          pasivo = cuenta["valor"].to_f.round(3)
        end
      end
      @caja_bancos.push(suma_caja_bancos.round(2))
      suma_caja_bancos = 0.0

      @cartera_bruta.push(suma_cartera_bruta.round(2))
      suma_cartera_bruta = 0.0

      @cartera_bruta_microcredito.push(cartera_bruta_micro.round(2))
      cartera_bruta_micro = 0.0

      @cartera_riesgo.push(suma_cartera_riesgo.round(2))
      suma_cartera_riesgo = 0.0

      suma_patrimonio = activo - pasivo
      @patrimonio.push(suma_patrimonio.round(2))
      suma_patrimonio = 0.0


    end

  end


  def set_layout
    return "agencias"
    super
  end

  private
  def extraer_fechas_entre(inicio, fin)
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

end