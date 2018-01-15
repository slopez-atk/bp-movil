import React from 'react';
import reqwest from 'reqwest';
import RaisedButton from 'material-ui/RaisedButton';

export class StagesGroup extends React.Component {
  constructor(props){
    super(props)
    this.add = this.add.bind(this);
    this.state = {
      stages: []
    }
  }

  add(stage){
    this.setState({
      stages: [stage].concat(this.state.stages)
    })
  }

  componentDidMount(){
    this.getStages();
  };


  getStages(){
    reqwest({
      url: this.props.url,
      method: 'GET'
    }).then(stages => {
      this.setState({
        stages: stages
      })
    })
  }

  render(){
    return "Hola mundo"
  }
}