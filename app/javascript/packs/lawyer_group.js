import React from 'react';
import WebpackerReact from 'webpacker-react';
import { LawyerForm } from '../lawyers/lawyer_form';
import reqwest from 'reqwest';
import RaisedButton from 'material-ui/RaisedButton';
import {Lawyers} from "../lawyers/lawyers";

export class LawyerGroup extends React.Component {
  constructor(props){
    super(props);
    this.add = this.add.bind(this);
    this.state = {
      lawyers: []
    }
  };

  add(lawyer){
    this.setState({
      lawyers: [lawyer].concat(this.state.lawyers)
    })
  };

  componentDidMount(){
     this.getLawyers();
  };

  getLawyers(){
    reqwest({
      url: '/lawyers.json',
      method: 'GET'
    }).then(lawyers => {
      this.setState({
        lawyers: lawyers
      })
    })
  };

  render(){
    return (
      <div>
        <h2 className="text-center">Listado de abogados</h2>
        <div className="row middle-xs">
          <div className="col-xs-10 col-xs-offset-1">
            <Lawyers lawyers={this.state.lawyers}/>
          </div>
        </div>

        <div className="col-xs-6 center-xs col-xs-offset-3">
          <div className="collapse" id="collapseExample">
            <div className="well">
              <h3>Ingresar nuevo abogado</h3>
              <LawyerForm add={this.add}/>
            </div>
          </div>
        </div>
      </div>
    )
  };
}
WebpackerReact.setup({LawyerGroup});