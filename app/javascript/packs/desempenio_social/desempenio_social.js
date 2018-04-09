import React from 'react';
import WebpackerReact from 'webpacker-react';
import BalanceSocialForm from "../../components/DesepenioSocial/DesempenioForms/BalanceSocialForm";


class DesempenioSocial extends React.Component{
  constructor(props){
    super(props);
  }

  getForms(){
    return(
      <div>
        <div className="col-xs-12 col-md-6">
          <BalanceSocialForm
            url='/desempenio_social/balance_social'
            title='Balance Social'
            authenticity_token={ this.props.authenticity_token }/>
        </div>
      </div>
    );
  }


  render(){
    return(
      <div className="row center-xs middle-xs">
        <div className="col-xs-12 col-md-11 top-space col-md-offset-4 bottom-space">
          { this.getForms() }
        </div>
      </div>
    );
  }
}

WebpackerReact.setup({DesempenioSocial});