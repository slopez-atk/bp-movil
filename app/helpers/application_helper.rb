module ApplicationHelper
  def img_juicio nombre_etapa, tipo_juicio
    src = ''
    if tipo_juicio == "bienes"
      case nombre_etapa
        when "Autorización proceso judicial"
          src = asset_path 'bienes/bienes_autorizacion_proceso.jpeg'
        when "Documentos habilitantes"
          src = asset_path 'bienes/bienes_documentos_habilitantes.jpeg'
        when "Acta de sorteo judicial"
          src = asset_path 'bienes/bienes_acta_sorteo_judicial.jpeg'
        when "Citaciones finalizadas - Razón"
          src = asset_path 'bienes/bienes_citaciones_finalizadas.jpeg'
        when "Sentencia"
          src = asset_path 'bienes/bienes_sentencia.jpeg'
        when "Liquidación"
          src = asset_path 'bienes/bienes_liquidacion.jpeg'
        when "Audiencia de ejecución"
          src = asset_path 'bienes/bienes_audiencia_de_ejecucion.jpeg'
        when "Ejecución de remate"
          src = asset_path 'bienes/bienes_ejecucion_de_remate.jpeg'
        when "Termina proceso"
          src = asset_path 'bienes/bienes_termina_proceso.jpeg'
      end

    elsif tipo_juicio == "sinbienes"

      case nombre_etapa
        when "Autorización proceso judicial"
          src = asset_path 'bienes/bienes_autorizacion_proceso.jpeg'
        when "Documentos habilitantes"
          src = asset_path 'bienes/bienes_documentos_habilitantes.jpeg'
        when "Acta sorteo judicial"
          src = asset_path 'bienes/bienes_acta_sorteo_judicial.jpeg'
        when "Citaciones finalizadas - razón"
          src = asset_path 'bienes/bienes_citaciones_finalizadas.jpeg'
        when "Sentencia"
          src = asset_path 'bienes/bienes_sentencia.jpeg'
        when "Liquidación"
          src = asset_path 'bienes/bienes_liquidacion.jpeg'
        when "Mandamiento de ejecución"
          src = asset_path 'sinbienes/sinbienes_mandamiento_ejecucion.jpeg'
      end

    else





    end
    html_style = "max-width: 100%;height:400px;background-size:cover;background-position: center;"
    html ="<img src='#{src}' style='#{html_style}'>"\
            "</header>"
    html.html_safe
  end

  def is_last_stage? stage
    if stage == "Termina proceso" or stage == "Mandamiento de ejecución" or stage == "Notificación de quiebra"
      return true
    end
    return false
  end

end
