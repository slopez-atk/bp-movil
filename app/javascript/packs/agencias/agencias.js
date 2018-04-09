import React from 'react';
import WebpackerReact from 'webpacker-react';
import IndicadoresFinancierosForm from "../../components/Agencias/AgenciasForms/IndicadoresFinancierosForm";


class Agencias extends React.Component{
  constructor(props){
    super(props);
  }

  getForms(){
    return(
      <div>
        <div className="col-xs-12 col-md-5">
          <IndicadoresFinancierosForm
            url='/agencias/indicadores_financieros'
            title='Informe de Cuentas por Agencia'
            authenticity_token={ this.props.authenticity_token }/>
        </div>

        <div className="col-xs-12 col-md-5">
          <IndicadoresFinancierosForm
            url='/agencias/indicadores_seps'
            title='Indicadores de la Seps'
            authenticity_token={ this.props.authenticity_token }/>
        </div>
      </div>
    );
  }


  render(){
    return(
      <div className="row center-xs middle-xs">
        <div className="col-xs-12 col-md-11  top-space bottom-space">
          { this.getForms() }
        </div>
      </div>
    );
  }
}

WebpackerReact.setup({Agencias});