module WorkersHelper

  def obtener_estado estado
    html_style = ""

    if estado == 'amarillo'
      estilo = 'label-warning'
      nombre = 'Amarillo'
    elsif estado == 'rojo'
      estilo = 'label-danger'
      nombre = 'Rojo'
    elsif estado == 'negro'
      estilo = 'label-default'
      nombre = 'Pagar'
    elsif estado == 'verde'
      estilo = 'label-primary'
      nombre = 'Verde'
    end
    html = "<span class='bottom-space label #{estilo}'>#{nombre}</span>"
    html.html_safe

  end
end
