import React from 'react';
import CreditosPorVencerForm from '../components/CreditsForms/CreditosPorVencerForm';
import CreditosVencidosForm from '../components/CreditsForms/CreditosVencidosForm';
import MatrizTransicionForm from '../components/CreditsForms/MatrizTransicionForm';
import CreditosConcedidosForm from '../components/CreditsForms/CreditosConcedidosForm';
import CosechasForm from "../components/CreditsForms/CosechasForm";
import IndicadoresVigentesForm from '../components/CreditsForms/IndicadoresVigentesForm';
import IndicadoresCreditosColocadosForm from '../components/CreditsForms/IndicadoresCreditosColocadosForm';

class Credits extends React.Component{
  constructor(props){
    super(props);

  }

  getForms(){
    if(this.props.permissions == 5 || this.props.permissions == 3){
      return(
        <div>
          <div className="col-xs-12 col-md-5">
            <MatrizTransicionForm
              url='/credits/matrices'
              authenticity_token={ this.props.authenticity_token }
              title= "Matriz de transicion"/>
          </div>

          <div className="col-xs-12 col-md-5">
            <CreditosVencidosForm
              url='/credits/creditos_vencidos'
              title='Consultar creditos vencidos'
              authenticity_token={ this.props.authenticity_token }/>
          </div>

          <div className="col-xs-12 col-md-5">
            <CreditosConcedidosForm
              url='/credits/creditos_concedidos'
              title='Consultar creditos concedidos'
              authenticity_token={ this.props.authenticity_token }/>
          </div>

          <div className="col-xs-12 col-md-5">
            <CosechasForm
              url='/credits/cosechas'
              title='Reporte de Cosechas'
              authenticity_token={ this.props.authenticity_token }/>
          </div>

          <div className="col-xs-12 col-md-5">
            <CreditosPorVencerForm
              authenticity_token={ this.props.authenticity_token }
              url = '/credits/creditos_por_vencer'
              title = 'Consultar creditos por vencer'/>
          </div>

          <div className="col-xs-12 col-md-5">
            <CreditosPorVencerForm
              authenticity_token={ this.props.authenticity_token }
              url = '/credits/cartera_recuperada'
              title = 'Cartera Recuperada'/>
          </div>

          <div className="col-xs-12 col-md-5">
            <IndicadoresVigentesForm
              url='/credits/indicadores_creditos_vigentes'
              title='Indicadores creditos vigentes'
              authenticity_token={ this.props.authenticity_token }/>
          </div>

          <div className="col-xs-12 col-md-5">
            <IndicadoresCreditosColocadosForm
              url='/credits/indicadores_creditos_colocados'
              title='Indicadores creditos colocados'
              authenticity_token={ this.props.authenticity_token }/>
          </div>


        </div>
      );
    } else if(this.props.permissions == 7){
      return(
        <div>

          <div className="col-xs-12 col-md-5">
            <CreditosVencidosForm
              url='/credits/creditos_vencidos'
              title='Consultar creditos vencidos'
              authenticity_token={ this.props.authenticity_token }/>
          </div>

          <div className="col-xs-12 col-md-5">
            <CreditosConcedidosForm
              url='/credits/creditos_concedidos'
              title='Consultar creditos concedidos'
              authenticity_token={ this.props.authenticity_token }/>
          </div>

          <div className="col-xs-12 col-md-5">
            <CreditosPorVencerForm
              authenticity_token={ this.props.authenticity_token }
              url = '/credits/creditos_por_vencer'
              title = 'Consultar creditos por vencer'/>
          </div>

          <div className="col-xs-12 col-md-5">
            <CreditosPorVencerForm
              authenticity_token={ this.props.authenticity_token }
              url = '/credits/cartera_recuperada'
              title = 'Cartera Recuperada'/>
          </div>

          <div className="col-xs-12 col-md-5">
            <IndicadoresVigentesForm
              url='/credits/indicadores_creditos_vigentes'
              title='Indicadores creditos vigentes'
              authenticity_token={ this.props.authenticity_token }/>
          </div>

          <div className="col-xs-12 col-md-5">
            <IndicadoresCreditosColocadosForm
              url='/credits/indicadores_creditos_colocados'
              title='Indicadores creditos colocados'
              authenticity_token={ this.props.authenticity_token }/>
          </div>
        </div>
      );
    } else if( this.props.permissions == 8){
      return(
        <div>
          <div className="col-xs-12 col-md-5">
            <MatrizTransicionForm
              url='/credits/matrices'
              authenticity_token={ this.props.authenticity_token }
              title= "Matriz de transicion"/>
          </div>

          <div className="col-xs-12 col-md-5">
            <CosechasForm
              url='/credits/cosechas'
              title='Reporte de Cosechas'
              authenticity_token={ this.props.authenticity_token }/>
          </div>

        </div>
      );
    }
  }

  render(){
    return(
      <div className="row center-xs middle-xs">
        <div className="col-xs-12 col-md-11 top-space col-md-offset-1 bottom-space">
          { this.getForms() }
        </div>
      </div>
    );
  }
}

WebpackerReact.setup({Credits});

