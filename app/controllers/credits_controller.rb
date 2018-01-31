class CreditsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_creditos

  def index
  end


  def creditos_por_vencer
    dia_inicio = params["diaInicio"]
    dia_fin = params["diaFin"]
    # Obtengo los creditos por semana
    @data = Oracledb.obtener_creditos_por_vencer Date.new(Date.current.year,Date.current.month,1), Date.new(Time.current.year,Time.current.month,-1), params['agencia'], params['asesor'], dia_inicio, dia_fin
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
      row['valor_recuperado'] = row['valor_recuperado'].to_f
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


  def cartera_recuperada
    dia_inicio = params["diaInicio"]
    dia_fin = params["diaFin"]
    # Obtengo los creditos por semana
    @data = Oracledb.cartera_recuperada Date.new(Date.current.year,Date.current.month,1), Date.new(Time.current.year,Time.current.month,-1), params['agencia'], params['asesor'], dia_inicio, dia_fin
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
      if params["asesor"]["nombre"].present?
        @data = Oracledb.obtener_creditos_de_asesor params["asesor"]["nombre"], params["asesor"]["diaInicio"],params["asesor"]["diaFin"],params["asesor"]["fecha"],""
      else
        @data = Oracledb.obtener_creditos_de_asesor "", params["asesor"]["diaInicio"],params["asesor"]["diaFin"],params["asesor"]["fecha"],params["asesor"]["sucursal"]
      end
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
       @saldos_cartera = Oracledb.obtener_saldo_cartera_asesor params["fecha"].to_date.strftime('%d-%m-%Y')
       @data = Oracledb.obtener_creditos_por_asesor params["fecha"].to_date.strftime('%d-%m-%Y'), params["diaInicio"], params["diaFin"]
       @data.each_with_index do |row, index|
         @data[index]["saldo_cartera"] = @saldos_cartera[index]["saldo_cartera"]
       end

     else
       @saldos_cartera = Oracledb.obtener_saldo_cartera_agencia params["fecha"].to_date.strftime('%d-%m-%Y')
       @data = Oracledb.obtener_creditos_por_agencia params["fecha"].to_date.strftime('%d-%m-%Y'), params["diaInicio"], params["diaFin"]
       @data.each_with_index do |row, index|
         @data[index]["saldo_cartera"] = @saldos_cartera[index]["saldo_cartera"]
       end
     end
  end

  def creditos_concedidos

    if params['consulta_detalles_asesor'].present?
      if params["asesor"]["nombre"].present?
        @data = Oracledb.obtener_creditos_concedidos_de_un_asesor params["asesor"]["nombre"], "","",params["asesor"]["diaInicio"], params["asesor"]["diaFin"]
      elsif params["asesor"]["sucursal"].present?
        @data = Oracledb.obtener_creditos_concedidos_de_un_asesor "", params["asesor"]["sucursal"],"",params["asesor"]["diaInicio"], params["asesor"]["diaFin"]
      else
        @data = Oracledb.obtener_creditos_concedidos_de_un_asesor "", "",params["asesor"]["grupo_credito"],params["asesor"]["diaInicio"], params["asesor"]["diaFin"]
      end


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


    # @data = Oracledb.obtener_creditos_por_asesor params["fecha"], params["diaInicio"], params["diaFin"]

    # @tipoReporte = "agencia"
    # @data = Oracledb.obtener_creditos_por_agencia params["fecha"], params["diaInicio"], params["diaFin"]
    if @tipoReporte == "asesor"
      @data = Oracledb.obtener_creditos_concedidos_por_asesor   params["diaInicio"], params["diaFin"]
      # @data = Oracledb.obtener_creditos_concedidos_por_asesor '', '', params["diaInicio"], params["diaFin"]
    elsif @tipoReporte == "agencia"
      @data = Oracledb.obtener_creditos_concedidos_por_agencia params["diaInicio"], params["diaFin"]
      # @data = Oracledb.obtener_creditos_concedidos_por_agencia '', '', params["diaInicio"], params["diaFin"]
    else
      @data = Oracledb.obtener_creditos_concedidos_por_grupo_credito  params["diaInicio"], params["diaFin"]
    end
  end

  def cosechas
    @fecha = params["fecha"]

    @agencia = params["agencia"]
    @asesor = params["asesor"]
    @hash_datos = Hash.new
    @hash_cantidades = Hash.new
    @hash_saldos = Hash.new

    @data = Oracledb.obtener_cosechas @fecha,  @agencia, @asesor


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

    # @hash_datos.each do |key, hash|
    #   @hash_datos[key] = @hash_datos[key].sort_by
    # end
    #
    # @hash_cantidades.each do |key, hash|
    #   @hash_cantidades[key] = @hash_cantidades[key].sort_by
    # end
    #
    # @hash_saldos.each do |key, hash|
    #   @hash_saldos[key] = @hash_saldos[key].sort_by
    # end

    # raise @hash_datos.to_yaml

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


  def indicadores_creditos_vigentes
    @data = Oracledb.indicadores_creditos_vigentes params["fecha"], params["diaInicio"], params["diaFin"], params["agencia"], params["asesor"]
    @hash_genero = Hash.new
    @hash_sector = Hash.new
    @hash_tipo_credito = Hash.new
    @hash_origen_recursos = Hash.new
    @hash_metodologia = Hash.new
    @hash_nivel_instruccion = Hash.new
    @hash_estado_civil = Hash.new
    @hash_rango_edad = Hash.new

    @generos = Array.new
    @sectores = Array.new
    @tipos_credito = Array.new
    @origenes_recursos = Array.new
    @metodologias = Array.new
    @niveles_instruccion = Array.new
    @estados_civiles = Array.new
    @rango_edades = Array.new

    @data.each do |row|
      row.stringify_keys!
      # Genero
      if @hash_genero[row["genero"]].nil?
        @hash_genero[row["genero"]] = {clave: row["genero"], cantidad: 1, saldo: row["saldo"].to_f.round(2), cap_activo: row["cap_activo"].to_f.round(2), cap_ndevenga: row["cap_ndevenga"].to_f.round(2), cartera_riesgo: row["cartera_riesgo"].to_f.round(2), cap_vencido: row["cap_vencido"].to_f.round(2)}
      else
        @hash_genero[row["genero"]][:cantidad] += 1
        @hash_genero[row["genero"]][:saldo] += row["saldo"].to_f.round(2)
        @hash_genero[row["genero"]][:cap_activo] += row["cap_activo"].to_f.round(2)
        @hash_genero[row["genero"]][:cap_ndevenga] += row["cap_ndevenga"].to_f.round(2)
        @hash_genero[row["genero"]][:cartera_riesgo] += row["cartera_riesgo"].to_f.round(2)
        @hash_genero[row["genero"]][:cap_vencido] += row["cap_vencido"].to_f.round(2)
      end

      #Sector
      if @hash_sector[row["sector"]].nil?
        @hash_sector[row["sector"]] = {clave: row["sector"], cantidad: 1, saldo: row["saldo"].to_f.round(2), cap_activo: row["cap_activo"].to_f.round(2), cap_ndevenga: row["cap_ndevenga"].to_f.round(2), cartera_riesgo: row["cartera_riesgo"].to_f.round(2), cap_vencido: row["cap_vencido"].to_f.round(2)}
      else
        @hash_sector[row["sector"]][:cantidad] += 1
        @hash_sector[row["sector"]][:saldo] += row["saldo"].to_f.round(2)
        @hash_sector[row["sector"]][:cap_activo] += row["cap_activo"].to_f.round(2)
        @hash_sector[row["sector"]][:cap_ndevenga] += row["cap_ndevenga"].to_f.round(2)
        @hash_sector[row["sector"]][:cartera_riesgo] += row["cartera_riesgo"].to_f.round(2)
        @hash_sector[row["sector"]][:cap_vencido] += row["cap_vencido"].to_f.round(2)
      end

      # Tipo de Credito
      if @hash_tipo_credito[row["tipo_credito"]].nil?
        @hash_tipo_credito[row["tipo_credito"]] = {clave: row["tipo_credito"], cantidad: 1, saldo: row["saldo"].to_f.round(2), cap_activo: row["cap_activo"].to_f.round(2), cap_ndevenga: row["cap_ndevenga"].to_f.round(2), cartera_riesgo: row["cartera_riesgo"].to_f.round(2), cap_vencido: row["cap_vencido"].to_f.round(2)}
      else
        @hash_tipo_credito[row["tipo_credito"]][:cantidad] += 1
        @hash_tipo_credito[row["tipo_credito"]][:saldo] += row["saldo"].to_f.round(2)
        @hash_tipo_credito[row["tipo_credito"]][:cap_activo] += row["cap_activo"].to_f.round(2)
        @hash_tipo_credito[row["tipo_credito"]][:cap_ndevenga] += row["cap_ndevenga"].to_f.round(2)
        @hash_tipo_credito[row["tipo_credito"]][:cartera_riesgo] += row["cartera_riesgo"].to_f.round(2)
        @hash_tipo_credito[row["tipo_credito"]][:cap_vencido] += row["cap_vencido"].to_f.round(2)
      end

      # Origen Recursos
      if @hash_origen_recursos[row["origen_recursos"]].nil?
        @hash_origen_recursos[row["origen_recursos"]] = {clave: row["origen_recursos"], cantidad: 1, saldo: row["saldo"].to_f.round(2), cap_activo: row["cap_activo"].to_f.round(2), cap_ndevenga: row["cap_ndevenga"].to_f.round(2), cartera_riesgo: row["cartera_riesgo"].to_f.round(2), cap_vencido: row["cap_vencido"].to_f.round(2)}
      else
        @hash_origen_recursos[row["origen_recursos"]][:cantidad] += 1
        @hash_origen_recursos[row["origen_recursos"]][:saldo] += row["saldo"].to_f.round(2)
        @hash_origen_recursos[row["origen_recursos"]][:cap_activo] += row["cap_activo"].to_f.round(2)
        @hash_origen_recursos[row["origen_recursos"]][:cap_ndevenga] += row["cap_ndevenga"].to_f.round(2)
        @hash_origen_recursos[row["origen_recursos"]][:cartera_riesgo] += row["cartera_riesgo"].to_f.round(2)
        @hash_origen_recursos[row["origen_recursos"]][:cap_vencido] += row["cap_vencido"].to_f.round(2)
      end

      # Metodologia
      if @hash_metodologia[row["metodologia"]].nil?
        @hash_metodologia[row["metodologia"]] = {clave: row["metodologia"], cantidad: 1, saldo: row["saldo"].to_f.round(2), cap_activo: row["cap_activo"].to_f.round(2), cap_ndevenga: row["cap_ndevenga"].to_f.round(2), cartera_riesgo: row["cartera_riesgo"].to_f.round(2), cap_vencido: row["cap_vencido"].to_f.round(2)}
      else
        @hash_metodologia[row["metodologia"]][:cantidad] += 1
        @hash_metodologia[row["metodologia"]][:saldo] += row["saldo"].to_f.round(2)
        @hash_metodologia[row["metodologia"]][:cap_activo] += row["cap_activo"].to_f.round(2)
        @hash_metodologia[row["metodologia"]][:cap_ndevenga] += row["cap_ndevenga"].to_f.round(2)
        @hash_metodologia[row["metodologia"]][:cartera_riesgo] += row["cartera_riesgo"].to_f.round(2)
        @hash_metodologia[row["metodologia"]][:cap_vencido] += row["cap_vencido"].to_f.round(2)
      end

      # Nivel de Instruccion
      if @hash_nivel_instruccion[row["instruccion"]].nil?
        @hash_nivel_instruccion[row["instruccion"]] = {clave: row["instruccion"], cantidad: 1, saldo: row["saldo"].to_f.round(2), cap_activo: row["cap_activo"].to_f.round(2), cap_ndevenga: row["cap_ndevenga"].to_f.round(2), cartera_riesgo: row["cartera_riesgo"].to_f.round(2), cap_vencido: row["cap_vencido"].to_f.round(2)}
      else
        @hash_nivel_instruccion[row["instruccion"]][:cantidad] += 1
        @hash_nivel_instruccion[row["instruccion"]][:saldo] += row["saldo"].to_f.round(2)
        @hash_nivel_instruccion[row["instruccion"]][:cap_activo] += row["cap_activo"].to_f.round(2)
        @hash_nivel_instruccion[row["instruccion"]][:cap_ndevenga] += row["cap_ndevenga"].to_f.round(2)
        @hash_nivel_instruccion[row["instruccion"]][:cartera_riesgo] += row["cartera_riesgo"].to_f.round(2)
        @hash_nivel_instruccion[row["instruccion"]][:cap_vencido] += row["cap_vencido"].to_f.round(2)
      end

      # Estado Civil
      if @hash_estado_civil[row["estado_civil"]].nil?
        @hash_estado_civil[row["estado_civil"]] = {clave: row["estado_civil"], cantidad: 1, saldo: row["saldo"].to_f.round(2), cap_activo: row["cap_activo"].to_f.round(2), cap_ndevenga: row["cap_ndevenga"].to_f.round(2), cartera_riesgo: row["cartera_riesgo"].to_f.round(2), cap_vencido: row["cap_vencido"].to_f.round(2)}
      else
        @hash_estado_civil[row["estado_civil"]][:cantidad] += 1
        @hash_estado_civil[row["estado_civil"]][:saldo] += row["saldo"].to_f.round(2)
        @hash_estado_civil[row["estado_civil"]][:cap_activo] += row["cap_activo"].to_f.round(2)
        @hash_estado_civil[row["estado_civil"]][:cap_ndevenga] += row["cap_ndevenga"].to_f.round(2)
        @hash_estado_civil[row["estado_civil"]][:cartera_riesgo] += row["cartera_riesgo"].to_f.round(2)
        @hash_estado_civil[row["estado_civil"]][:cap_vencido] += row["cap_vencido"].to_f.round(2)
      end

      # Rangos de Edad
      if @hash_rango_edad[row["rango_edad"]].nil?
        @hash_rango_edad[row["rango_edad"]] = {clave: row["rango_edad"], cantidad: 1, saldo: row["saldo"].to_f.round(2), cap_activo: row["cap_activo"].to_f.round(2), cap_ndevenga: row["cap_ndevenga"].to_f.round(2), cartera_riesgo: row["cartera_riesgo"].to_f.round(2), cap_vencido: row["cap_vencido"].to_f.round(2)}
      else
        @hash_rango_edad[row["rango_edad"]][:cantidad] += 1
        @hash_rango_edad[row["rango_edad"]][:saldo] += row["saldo"].to_f.round(2)
        @hash_rango_edad[row["rango_edad"]][:cap_activo] += row["cap_activo"].to_f.round(2)
        @hash_rango_edad[row["rango_edad"]][:cap_ndevenga] += row["cap_ndevenga"].to_f.round(2)
        @hash_rango_edad[row["rango_edad"]][:cartera_riesgo] += row["cartera_riesgo"].to_f.round(2)
        @hash_rango_edad[row["rango_edad"]][:cap_vencido] += row["cap_vencido"].to_f.round(2)
      end

      # Rangos Ingreso
      # if @hash_metodologia[row["metodologia"]].nil?
      #   @hash_metodologia[row["metodologia"]] = {clave: row["origen_recursos"], cantidad: 1, saldo: row["saldo"].to_f.round(2), cap_activo: row["cap_activo"].to_f.round(2), cap_ndevenga: row["cap_ndevenga"].to_f.round(2), cartera_riesgo: row["cartera_riesgo"].to_f.round(2), cap_vencido: row["cap_vencido"].to_f.round(2)}
      # else
      #   @hash_metodologia[row["metodologia"]][:cantidad] += 1
      #   @hash_metodologia[row["metodologia"]][:saldo] += row["saldo"].to_f.round(2)
      #   @hash_metodologia[row["metodologia"]][:cap_activo] += row["cap_activo"].to_f.round(2)
      #   @hash_metodologia[row["metodologia"]][:cap_ndevenga] += row["cap_ndevenga"].to_f.round(2)
      #   @hash_metodologia[row["metodologia"]][:cartera_riesgo] += row["cartera_riesgo"].to_f.round(2)
      #   @hash_metodologia[row["metodologia"]][:cap_vencido] += row["cap_vencido"].to_f.round(2)
      # end
    end


    @hash_genero.each do |row|
      row[1].stringify_keys!
      row[1]["saldo"] = row[1]["saldo"].round(2)
      row[1]["cap_activo"] = row[1]["cap_activo"].round(2)
      row[1]["cap_ndevenga"] = row[1]["cap_ndevenga"].round(2)
      row[1]["cartera_riesgo"] = row[1]["cartera_riesgo"].round(2)
      row[1]["cap_vencido"] = row[1]["cap_vencido"].round(2)
      @generos.push(row[1])
    end
    @hash_sector.each do |row|
      row[1].stringify_keys!
      row[1]["saldo"] = row[1]["saldo"].round(2)
      row[1]["cap_activo"] = row[1]["cap_activo"].round(2)
      row[1]["cap_ndevenga"] = row[1]["cap_ndevenga"].round(2)
      row[1]["cartera_riesgo"] = row[1]["cartera_riesgo"].round(2)
      row[1]["cap_vencido"] = row[1]["cap_vencido"].round(2)
      @sectores.push(row[1])
    end
    @hash_tipo_credito.each do |row|
      row[1].stringify_keys!
      row[1]["saldo"] = row[1]["saldo"].round(2)
      row[1]["cap_activo"] = row[1]["cap_activo"].round(2)
      row[1]["cap_ndevenga"] = row[1]["cap_ndevenga"].round(2)
      row[1]["cartera_riesgo"] = row[1]["cartera_riesgo"].round(2)
      row[1]["cap_vencido"] = row[1]["cap_vencido"].round(2)
      @tipos_credito.push(row[1])
    end
    @hash_origen_recursos.each do |row|
      row[1].stringify_keys!
      row[1]["saldo"] = row[1]["saldo"].round(2)
      row[1]["cap_activo"] = row[1]["cap_activo"].round(2)
      row[1]["cap_ndevenga"] = row[1]["cap_ndevenga"].round(2)
      row[1]["cartera_riesgo"] = row[1]["cartera_riesgo"].round(2)
      row[1]["cap_vencido"] = row[1]["cap_vencido"].round(2)
      @origenes_recursos.push(row[1])
    end
    @hash_metodologia.each do |row|
      row[1].stringify_keys!
      row[1]["saldo"] = row[1]["saldo"].round(2)
      row[1]["cap_activo"] = row[1]["cap_activo"].round(2)
      row[1]["cap_ndevenga"] = row[1]["cap_ndevenga"].round(2)
      row[1]["cartera_riesgo"] = row[1]["cartera_riesgo"].round(2)
      row[1]["cap_vencido"] = row[1]["cap_vencido"].round(2)
      @metodologias.push(row[1])
    end
    @hash_estado_civil.each do |row|
      row[1].stringify_keys!
      row[1]["saldo"] = row[1]["saldo"].round(2)
      row[1]["cap_activo"] = row[1]["cap_activo"].round(2)
      row[1]["cap_ndevenga"] = row[1]["cap_ndevenga"].round(2)
      row[1]["cartera_riesgo"] = row[1]["cartera_riesgo"].round(2)
      row[1]["cap_vencido"] = row[1]["cap_vencido"].round(2)
      @estados_civiles.push(row[1])
    end
    @hash_nivel_instruccion.each do |row|
      row[1].stringify_keys!
      row[1]["saldo"] = row[1]["saldo"].round(2)
      row[1]["cap_activo"] = row[1]["cap_activo"].round(2)
      row[1]["cap_ndevenga"] = row[1]["cap_ndevenga"].round(2)
      row[1]["cartera_riesgo"] = row[1]["cartera_riesgo"].round(2)
      row[1]["cap_vencido"] = row[1]["cap_vencido"].round(2)
      @niveles_instruccion.push(row[1])
    end
    @hash_rango_edad.each do |row|
      row[1].stringify_keys!
      row[1]["saldo"] = row[1]["saldo"].round(2)
      row[1]["cap_activo"] = row[1]["cap_activo"].round(2)
      row[1]["cap_ndevenga"] = row[1]["cap_ndevenga"].round(2)
      row[1]["cartera_riesgo"] = row[1]["cartera_riesgo"].round(2)
      row[1]["cap_vencido"] = row[1]["cap_vencido"].round(2)
      @rango_edades.push(row[1])
    end

  end

  def indicadores_creditos_colocados
    @data = Oracledb.indicadores_creditos_colocados params["fechaInicio"], params["fechaFin"], params["diaInicio"], params["diaFin"], params["agencia"], params["asesor"]

    @hash_genero = Hash.new
    @hash_sector = Hash.new
    @hash_tipo_credito = Hash.new
    @hash_origen_recursos = Hash.new
    @hash_metodologia = Hash.new
    @hash_nivel_instruccion = Hash.new
    @hash_estado_civil = Hash.new
    @hash_rango_edad = Hash.new

    # Voy a transformar el hash en un array por eso instancio un array para cada hash
    @generos = Array.new
    @sectores = Array.new
    @tipos_credito = Array.new
    @origenes_recursos = Array.new
    @metodologias = Array.new
    @niveles_instruccion = Array.new
    @estados_civiles = Array.new
    @rango_edades = Array.new

    @data.each do |row|
      row.stringify_keys!
      # Genero
      if @hash_genero[row["genero"]].nil?
        @hash_genero[row["genero"]] = {clave: row["genero"], cantidad: 1, monto_real: row["monto_real"].to_f.round(2)}
      else
        @hash_genero[row["genero"]][:cantidad] += 1
        @hash_genero[row["genero"]][:monto_real] += row["monto_real"].to_f.round(2)

      end

      #Sector
      if @hash_sector[row["sector"]].nil?
        @hash_sector[row["sector"]] = {clave: row["sector"], cantidad: 1, monto_real: row["monto_real"].to_f.round(2)}
      else
        @hash_sector[row["sector"]][:cantidad] += 1
        @hash_sector[row["sector"]][:monto_real] += row["monto_real"].to_f.round(2)

      end

      # Tipo de Credito
      if @hash_tipo_credito[row["tipo_credito"]].nil?
        @hash_tipo_credito[row["tipo_credito"]] = {clave: row["tipo_credito"], cantidad: 1, monto_real: row["monto_real"].to_f.round(2)}
      else
        @hash_tipo_credito[row["tipo_credito"]][:cantidad] += 1
        @hash_tipo_credito[row["tipo_credito"]][:monto_real] += row["saldo"].to_f.round(2)

      end

      # Origen Recursos
      if @hash_origen_recursos[row["origen_recursos"]].nil?
        @hash_origen_recursos[row["origen_recursos"]] = {clave: row["origen_recursos"], cantidad: 1, monto_real: row["monto_real"].to_f.round(2)}
      else
        @hash_origen_recursos[row["origen_recursos"]][:cantidad] += 1
        @hash_origen_recursos[row["origen_recursos"]][:monto_real] += row["monto_real"].to_f.round(2)
      end

      # Metodologia
      if @hash_metodologia[row["metodologia"]].nil?
        @hash_metodologia[row["metodologia"]] = {clave: row["origen_recursos"], cantidad: 1, monto_real: row["monto_real"].to_f.round(2)}
      else
        @hash_metodologia[row["metodologia"]][:cantidad] += 1
        @hash_metodologia[row["metodologia"]][:monto_real] += row["monto_real"].to_f.round(2)

      end


      # Nivel de Instruccion
      if @hash_nivel_instruccion[row["instruccion"]].nil?
        @hash_nivel_instruccion[row["instruccion"]] = {clave: row["instruccion"], cantidad: 1, monto_real: row["monto_real"].to_f.round(2)}
      else
        @hash_nivel_instruccion[row["instruccion"]][:cantidad] += 1
        @hash_nivel_instruccion[row["instruccion"]][:monto_real] += row["monto_real"].to_f.round(2)
      end

      # Estado Civil
      if @hash_estado_civil[row["estado_civil"]].nil?
        @hash_estado_civil[row["estado_civil"]] = {clave: row["estado_civil"], cantidad: 1, monto_real: row["monto_real"].to_f.round(2)}
      else
        @hash_estado_civil[row["estado_civil"]][:cantidad] += 1
        @hash_estado_civil[row["estado_civil"]][:monto_real] += row["monto_real"].to_f.round(2)

      end

      # Rangos de Edad
      if @hash_rango_edad[row["rango_edad"]].nil?
        @hash_rango_edad[row["rango_edad"]] = {clave: row["rango_edad"], cantidad: 1, monto_real: row["monto_real"].to_f.round(2)}
      else
        @hash_rango_edad[row["rango_edad"]][:cantidad] += 1
        @hash_rango_edad[row["rango_edad"]][:monto_real] += row["monto_real"].to_f.round(2)

      end

      # Rangos Ingreso
      # if @hash_metodologia[row["metodologia"]].nil?
      #   @hash_metodologia[row["metodologia"]] = {clave: row["origen_recursos"], cantidad: 1, saldo: row["saldo"].to_f.round(2), cap_activo: row["cap_activo"].to_f.round(2), cap_ndevenga: row["cap_ndevenga"].to_f.round(2), cartera_riesgo: row["cartera_riesgo"].to_f.round(2), cap_vencido: row["cap_vencido"].to_f.round(2)}
      # else
      #   @hash_metodologia[row["metodologia"]][:cantidad] += 1
      #   @hash_metodologia[row["metodologia"]][:saldo] += row["saldo"].to_f.round(2)
      #   @hash_metodologia[row["metodologia"]][:cap_activo] += row["cap_activo"].to_f.round(2)
      #   @hash_metodologia[row["metodologia"]][:cap_ndevenga] += row["cap_ndevenga"].to_f.round(2)
      #   @hash_metodologia[row["metodologia"]][:cartera_riesgo] += row["cartera_riesgo"].to_f.round(2)
      #   @hash_metodologia[row["metodologia"]][:cap_vencido] += row["cap_vencido"].to_f.round(2)
      # end
    end


    @hash_genero.each do |row|
      row[1].stringify_keys!
      row[1]["monto_real"] = row[1]["monto_real"].round(2)
      @generos.push(row[1])
    end
    @hash_sector.each do |row|
      row[1].stringify_keys!
      row[1]["monto_real"] = row[1]["monto_real"].round(2)
      @sectores.push(row[1])
    end
    @hash_tipo_credito.each do |row|
      row[1].stringify_keys!
      row[1]["monto_real"] = row[1]["monto_real"].round(2)

      @tipos_credito.push(row[1])
    end
    @hash_origen_recursos.each do |row|
      row[1].stringify_keys!
      row[1]["monto_real"] = row[1]["monto_real"].round(2)

      @origenes_recursos.push(row[1])
    end
    @hash_metodologia.each do |row|
      row[1].stringify_keys!
      row[1]["monto_real"] = row[1]["monto_real"].round(2)
      @metodologias.push(row[1])
    end
    @hash_estado_civil.each do |row|
      row[1].stringify_keys!
      row[1]["monto_real"] = row[1]["monto_real"].round(2)
      @estados_civiles.push(row[1])
    end
    @hash_nivel_instruccion.each do |row|
      row[1].stringify_keys!
      row[1]["monto_real"] = row[1]["monto_real"].round(2)
      @niveles_instruccion.push(row[1])
    end
    @hash_rango_edad.each do |row|
      row[1].stringify_keys!
      row[1]["monto_real"] = row[1]["monto_real"].round(2)
      @rango_edades.push(row[1])
    end
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
