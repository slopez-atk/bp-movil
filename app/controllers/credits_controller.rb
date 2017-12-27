class CreditsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_creditos

  def index
  end


  def creditos_por_vencer
    # Obtengo los creditos por semana
    @data = Oracledb.obtener_creditos_por_vencer Date.new(Date.current.year,Date.current.month,1), Date.new(Time.current.year,Time.current.month,-1), params['agencia'], params['asesor']
    # @secondWeek = Oracledb.obtener_creditos_por_vencer Date.new(Date.current.year,Date.current.month,8), Date.new(Time.current.year,Time.current.month,14), params['agencia'], params['asesor'],'secondWeek'
    # @thirdWeek = Oracledb.obtener_creditos_por_vencer Date.new(Date.current.year,Date.current.month,15), Date.new(Time.current.year,Time.current.month,21), params['agencia'], params['asesor'],'thirdWeek'
    # @fourthWeek = Oracledb.obtener_creditos_por_vencer Date.new(Date.current.year,Date.current.month,22), Date.new(Time.current.year,Time.current.month,-1), params['agencia'],params['asesor'],'fourthWeek'
    fecha1Semana1 = Date.new(Date.current.year,Date.current.month,1)
    fecha2Semana1 = Date.new(Date.current.year,Date.current.month,7)
    fecha1Semana2 = Date.new(Date.current.year,Date.current.month,8)
    fecha2Semana2 = Date.new(Date.current.year,Date.current.month,14)
    fecha1Semana3 = Date.new(Date.current.year,Date.current.month,15)
    fecha2Semana3 = Date.new(Date.current.year,Date.current.month,21)
    fecha1Semana4 = Date.new(Date.current.year,Date.current.month,22)
    fecha2Semana4 = Date.new(Date.current.year,Date.current.month,-1)

    @firstWeek = []
    @secondWeek = []
    @thirdWeek = []
    @fourthWeek = []

    @data.each do |row|
      row['saldo'] = row['saldo'].to_f
      row['provision'] = row['provision'].to_f
    end

    @data.each do |credit|
      credit.stringify_keys!
      if credit["fecha"].to_date.between?(fecha1Semana1, fecha2Semana1)
        @firstWeek.push(credit)
      elsif credit["fecha"].to_date.between?(fecha1Semana2, fecha2Semana2)
        @secondWeek.push(credit)
      elsif credit["fecha"].to_date.between?(fecha1Semana3, fecha2Semana3)
        @thirdWeek.push(credit)
      elsif credit["fecha"].to_date.between?(fecha1Semana4, fecha2Semana4)
        @fourthWeek.push(credit)
      end
    end



    # @secondWeek.each do |row|
    #   row['saldo'] = row['saldo'].to_f
    #   row['provision'] = row['provision'].to_f
    # end
    # @thirdWeek.each do |row|
    #   row['saldo'] = row['saldo'].to_f
    #   row['provision'] = row['provision'].to_f
    # end
    # @fourthWeek.each do |row|
    #   row['saldo'] = row['saldo'].to_f
    #   row['provision'] = row['provision'].to_f
    # end


    # Obtengo un array lleno de las fechas intermedias entre las semanas
    @firstArrayDates= Array.new
    (Date.new(Date.current.year,Date.current.month,1)..Date.new(Time.current.year,Time.current.month,7)).each do |date|
      @firstArrayDates.push(date.strftime('%d-%m-%Y'))
    end
    @secondArrayDates= Array.new
    (Date.new(Date.current.year,Date.current.month,8)..Date.new(Time.current.year,Time.current.month,14)).each do |date|
      @secondArrayDates.push(date.strftime('%d-%m-%Y'))
    end
    @thirdArrayDates= Array.new
    (Date.new(Date.current.year,Date.current.month,15)..Date.new(Time.current.year,Time.current.month,21)).each do |date|
      @thirdArrayDates.push(date.strftime('%d-%m-%Y'))
    end
    @fourthArrayDates= Array.new
    (Date.new(Date.current.year,Date.current.month,22)..Date.new(Time.current.year,Time.current.month,-1)).each do |date|
      @fourthArrayDates.push(date.strftime('%d-%m-%Y'))
    end

    # Creo un hash de arrays cuyas llaves son las fechas extraidas entre semanas
    @firstHash = Hash.new(Array.new)
    @firstArrayDates.each do |fecha|
      @firstHash[fecha] = []
    end

    @secondHash = Hash.new(Array.new)
    @secondArrayDates.each do |fecha|
      @secondHash[fecha] = []
    end

    @thirdHash = Hash.new(Array.new)
    @thirdArrayDates.each do |fecha|
      @thirdHash[fecha] = []
    end

    @fourthHash = Hash.new(Array.new)
    @fourthArrayDates.each do |fecha|
      @fourthHash[fecha] = []
    end


    # Lleno el hash con los creditos, clasificados por sus llaves y fechas
    @firstWeek.each do |credit|
      array = Array.new
      credit["fecha"] = credit["fecha"].to_date.strftime('%d-%m-%Y')
      array = @firstHash[credit["fecha"]]
      array.push(credit)
      @firstHash[credit["fecha"]] = array
    end

    @secondWeek.each do |credit|
      array = Array.new
      credit["fecha"] = credit["fecha"].to_date.strftime('%d-%m-%Y')
      array = @secondHash[credit["fecha"]]
      array.push(credit)
      @secondHash[credit["fecha"]] = array
    end

    @thirdWeek.each do |credit|
      array = Array.new
      credit["fecha"] = credit["fecha"].to_date.strftime('%d-%m-%Y')
      array = @thirdHash[credit["fecha"]]
      array.push(credit)
      @thirdHash[credit["fecha"]] = array
    end

    @fourthWeek.each do |credit|
      array = Array.new
      credit["fecha"] = credit["fecha"].to_date.strftime('%d-%m-%Y')
      array = @fourthHash[credit["fecha"]]
      array.push(credit)
      @fourthHash[credit["fecha"]] = array
    end


  end

  def creditos_vencidos
    if params['consulta_detalles_asesor'].present?
      @data = Oracledb.obtener_creditos_de_asesor params["asesor"]["nombre"], params["asesor"]["diaInicio"],params["asesor"]["diaFin"],params["asesor"]["fecha"]
      respond_to do |format|
        format.json { render :layout => false, :text => @data.to_json }
      end
      return
    end

    @tipoReporte = params['tipoReporte']
    @diaInicio = params["diaInicio"]
    @diaFin = params["diaFin"]
    @fecha = params["fecha"]

    # @data = Oracledb.obtener_creditos_por_asesor params["fecha"], params["diaInicio"], params["diaFin"]

    # @tipoReporte = "asesor"
    # @data = Oracledb.obtener_creditos_por_agencia params["fecha"], params["diaInicio"], params["diaFin"]
     if @tipoReporte == "asesor"
       @data = Oracledb.obtener_creditos_por_asesor params["fecha"].to_date.strftime('%d-%m-%Y'), params["diaInicio"], params["diaFin"]
     else
       @data = Oracledb.obtener_creditos_por_agencia params["fecha"].to_date.strftime('%d-%m-%Y'), params["diaInicio"], params["diaFin"]
     end
  end

  def creditos_concedidos

    if params['consulta_detalles_asesor'].present?
      @data = Oracledb.obtener_creditos_concedidos_de_un_asesor params["asesor"]["nombre"], params["asesor"]["fechaInicio"],params["asesor"]["fechaFin"],params["asesor"]["diaInicio"], params["asesor"]["diaFin"]
      @data.to_json
      respond_to do |format|
        format.json { render :layout => false, :text => @data }
      end
      return
    end

    # @tipoReporte = "agencia"
    @tipoReporte = params['tipoReporte']
    @diaInicio = params["diaInicio"]
    @diaFin = params["diaFin"]
    @fechaInicio = params["fechaInicio"]
    @fechaFin = params["fechaFin"]

    # @data = Oracledb.obtener_creditos_por_asesor params["fecha"], params["diaInicio"], params["diaFin"]

    # @tipoReporte = "agencia"
    # @data = Oracledb.obtener_creditos_por_agencia params["fecha"], params["diaInicio"], params["diaFin"]
    if @tipoReporte == "asesor"
      @data = Oracledb.obtener_creditos_concedidos_por_asesor params["fechaInicio"].to_date.strftime('%d-%m-%Y'), params["fechaFin"].to_date.strftime('%d-%m-%Y'), params["diaInicio"], params["diaFin"]
      # @data = Oracledb.obtener_creditos_concedidos_por_asesor '', '', params["diaInicio"], params["diaFin"]
    else
      @data = Oracledb.obtener_creditos_concedidos_por_agencia params["fechaInicio"].to_date.strftime('%d-%m-%Y'), params["fechaFin"].to_date.strftime('%d-%m-%Y'), params["diaInicio"], params["diaFin"]
      # @data = Oracledb.obtener_creditos_concedidos_por_agencia '', '', params["diaInicio"], params["diaFin"]
    end
  end

  def cosechas
    @fecha = params["fecha"]
    @dia_inicio = params["diaInicio"]
    @dia_fin = params["diaFin"]
    @agencia = params["agencia"]
    @asesor = params["asesor"]
    @hash_datos = Hash.new
    @hash_cantidades = Hash.new
    @hash_saldos = Hash.new

    @data = Oracledb.obtener_cosechas @fecha, @diaInicio, @dia_fin, @agencia, @asesor

    @data.each do |row|
      row.stringify_keys!
      year = row["fecha_concesion"].to_date.strftime('%Y')
      month = row["fecha_concesion"].to_date.strftime('%m')
      if @hash_datos[year].nil?

        @hash_datos[year] = {}
        @hash_cantidades[year] = {}
        @hash_saldos[year] = {}


        @hash_datos[year][month] = []
        @hash_cantidades[year][month] = 1
        @hash_saldos[year][month] = row["cartera_riesgo"].to_f.round(2)


        @hash_datos[year][month] = @hash_datos[year][month].push(row)

      else
        temp = @hash_datos[year]
        temp_cantidades = @hash_cantidades[year]
        temp_saldos = @hash_saldos[year]
        if temp[month].nil?
          temp[month] = []
          temp_cantidades[month] = 0
          temp_saldos[month] = 0


          temp[month] = temp[month].push(row)
          temp_cantidades[month] = temp_cantidades[month] + 1
          temp_saldos[month] = temp_saldos[month] + + row["cartera_riesgo"].to_f.round(2)

          @hash_datos[year] = temp
          @hash_cantidades[year] = temp_cantidades
          @hash_saldos[year] = temp_saldos
        else
          array = @hash_datos[year][month]
          cantidad = @hash_cantidades[year][month]
          saldo = @hash_saldos[year][month]


          array.push(row)
          @hash_datos[year][month] = array
          @hash_cantidades[year][month] = cantidad + 1
          @hash_saldos[year][month] = saldo + row["cartera_riesgo"].to_f.round(2)

        end
      end
    end

  end

  def matrices
    data = Oracledb.datos_matriz_transicion params["fecha1"], params["fecha2"], params["agencia"], params["asesor"]
    @hash_datos = Hash.new
    @hash_cantidades = Hash.new
    @hash_saldos = Hash.new
    @saldo_total = 0


    data.each do |row|
      row.stringify_keys!
      # Si el hash["A1"] es nil quiere decir que tengo q crearlo
      if @hash_datos[row['calificacion_inicial']].nil?
        # Creo un key en el hash con la calificacion inicial
        @hash_datos[row['calificacion_inicial']] = {}
        @hash_cantidades[row['calificacion_inicial']] = {}
        @hash_saldos[row['calificacion_inicial']] = {}

        # Creo un subkey con la calificacion final
        @hash_datos[row['calificacion_inicial']][row["calificacion_final"]] = []
        @hash_cantidades[row['calificacion_inicial']][row["calificacion_final"]] = 1
        @hash_saldos[row['calificacion_inicial']][row["calificacion_final"]] = row["cap_saldo"].to_f.round(2)

        # Guardo en hash["A1"]["A1"] la fila
        @hash_datos[row['calificacion_inicial']][row["calificacion_final"]] = @hash_datos[row['calificacion_inicial']][row["calificacion_final"]].push(row)
      else
        # Caso contrario quiere decir que ya existe un hash["A1"]
        # Guardo en un temporal everything lo que tenga hash["A1"]
        temp = @hash_datos[row['calificacion_inicial']]
        temp_cantidades = @hash_cantidades[row['calificacion_inicial']]
        temp_saldos = @hash_saldos[row['calificacion_inicial']]
        # Pregunto si existe el subkey que quiero ingresar
        if temp[row["calificacion_final"]].nil?
          # Si no existe creo uno
          temp[row["calificacion_final"]] = []
          temp_cantidades[row["calificacion_final"]] = 0
          temp_saldos[row["calificacion_final"]] = 0
          # Hago push la fila en la posicion
          temp[row["calificacion_final"]] = temp[row["calificacion_final"]].push(row)
          temp_cantidades[row["calificacion_final"]] = temp_cantidades[row["calificacion_final"]] + 1
          temp_saldos[row["calificacion_final"]] = temp_saldos[row["calificacion_final"]] + row["cap_saldo"].to_f.round(2)
          # Reasigno el temp con el nuevo campo a hash["A1"]
          @hash_datos[row['calificacion_inicial']] = temp
          @hash_cantidades[row['calificacion_inicial']] = temp_cantidades
          @hash_saldos[row['calificacion_inicial']] = temp_saldos
        else
          # Caso contrario ya existe una llave hash["A1"]["A1"]
          array = @hash_datos[row['calificacion_inicial']][row["calificacion_final"]]
          cantidad = @hash_cantidades[row['calificacion_inicial']][row["calificacion_final"]]
          saldo = @hash_saldos[row['calificacion_inicial']][row["calificacion_final"]]

          # Hago push la nueva fila
          array.push(row)
          @hash_datos[row['calificacion_inicial']][row["calificacion_final"]] = array
          @hash_cantidades[row['calificacion_inicial']][row["calificacion_final"]] = cantidad + 1
          @hash_saldos[row['calificacion_inicial']][row["calificacion_final"]] = saldo + row["cap_saldo"].to_f.round(2)
        end
      end
    end
    @matriz = [
              [["A1","A1"],["A1","A2"],["A1","A3"],["A1","B1"],["A1","B2"],["A1","C1"],["A1","C2"],["A1","D"],["A1","E"]],
              [["A2","A1"],["A2","A2"],["A2","A3"],["A2","B1"],["A2","B2"],["A2","C1"],["A2","C2"],["A2","D"],["A2","E"]],
              [["A3","A1"],["A3","A2"],["A3","A3"],["A3","B1"],["A3","B2"],["A3","C1"],["A3","C2"],["A3","D"],["A3","E"]],
              [["B1","A1"],["B1","A2"],["B1","A3"],["B1","B1"],["B1","B2"],["B1","C1"],["B1","C2"],["B1","D"],["B1","E"]],
              [["B2","A1"],["B2","A2"],["B2","A3"],["B2","B1"],["B2","B2"],["B2","C1"],["B2","C2"],["B2","D"],["B2","E"]],
              [["C1","A1"],["C1","A2"],["C1","A3"],["C1","B1"],["C1","B2"],["C1","C1"],["C1","C2"],["C1","D"],["C1","E"]],
              [["C2","A1"],["C2","A2"],["C2","A3"],["C2","B1"],["C2","B2"],["C2","C1"],["C2","C2"],["C2","D"],["C2","E"]],
              [["D","A1"],["D","A2"],["D","A3"],["D","B1"],["D","B2"],["D","C1"],["D","C2"],["D","D"],["D","E"]],
              [["E","A1"],["E","A2"],["E","A3"],["E","B1"],["E","B2"],["E","C1"],["E","C2"],["E","D"],["E","E"]]
    ]


  end

  def clientes_vip
  end

  def set_layout
    return "creditos"
    super
  end

  protected
  def authenticate_creditos
    unless current_user.permissions == 5 || current_user.permissions == 7 || current_user.permissions == 3 || current_user.permissions == 8
      redirect_to root_path, notice: "No estás autorizado!"
    end
  end
end
