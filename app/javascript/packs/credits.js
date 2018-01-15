import React from 'react';
import WebpackerReact from 'webpacker-react';
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
    return(
      <div>
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

