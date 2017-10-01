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
          src = asset_path 'sinbienes/autorizacion_proceso.jpeg'
        when "Documentos habilitantes"
          src = asset_path 'sinbienes/documentos_habilitantes.jpeg'
        when "Acta sorteo judicial"
          src = asset_path 'sinbienes/acta_sorteo_judicial.jpeg'
        when "Citaciones finalizadas - razón"
          src = asset_path 'sinbienes/citaciones_finalizadas.jpeg'
        when "Sentencia"
          src = asset_path 'sinbienes/sentencia.jpeg'
        when "Liquidación"
          src = asset_path 'sinbienes/Liquidacion.jpeg'
        when "Mandamiento de ejecución"
          src = asset_path 'sinbienes/mandamiento_ejecucion.jpeg'
      end

    else

      case nombre_etapa
        when "Mandamiento de ejecución"
          src = asset_path 'insolvencia/mandamiento_ejecucion.jpeg'
        when "Acta de sorteo judicial"
          src = asset_path 'insolvencia/acta_sorteo.jpeg'
        when "Citaciones finalizadas"
          src = asset_path 'insolvencia/citaciones_finalizadas.jpeg'
        when "Notificación pública"
          src = asset_path 'insolvencia/notificaciones_publicas.jpeg'
        when "Síndico de quiebra"
          src = asset_path 'insolvencia/sindico_quiebra.jpeg'
        when "Notificación de quiebra"
          src = asset_path 'insolvencia/notificacion_quiebra.jpeg'
      end





    end
    html_style = ""
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
