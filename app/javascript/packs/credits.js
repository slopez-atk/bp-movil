import React from 'react';
import CreditosPorVencerForm from '../components/CreditsForms/CreditosPorVencerForm';
import CreditosVencidosForm from '../components/CreditsForms/CreditosVencidosForm';
import MatrizTransicionForm from '../components/CreditsForms/MatrizTransicionForm';
import CreditosConcedidosForm from '../components/CreditsForms/CreditosConcedidosForm';

class Credits extends React.Component{
  constructor(props){
    super(props);

  }

  render(){
    return(
      <div className="row center-xs middle-xs">
        <div className="col-xs-12 col-md-11 top-space col-md-offset-1">
          <CreditosPorVencerForm
            authenticity_token={ this.props.authenticity_token }
            url={ this.props.url}
            title={ this.props.title}/>

          <CreditosVencidosForm
            url='/credits/creditos_vencidos'
            title='Consultar creditos vencidos'
            authenticity_token={ this.props.authenticity_token }/>

          <MatrizTransicionForm
            url='/credits/matrices'
            authenticity_token={ this.props.authenticity_token }
            title= "Matriz de transicion"/>

          <CreditosConcedidosForm
            url='/credits/creditos_concedidos'
            title='Consultar creditos concedidos'
            authenticity_token={ this.props.authenticity_token }/>
        </div>


      </div>
    );
  }
}

WebpackerReact.setup({Credits});

