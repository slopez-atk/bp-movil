import React from 'react';
import CreditosPorVencerForm from '../components/CreditsForms/CreditosPorVencerForm';

class Credits extends React.Component{
  constructor(props){
    super(props);

  }

  render(){
    return(
      <div>
        <CreditosPorVencerForm
          authenticity_token={ this.props.authenticity_token }
          url={ this.props.url}
          title={ this.props.title}/>
      </div>
    );
  }
}

WebpackerReact.setup({Credits});

