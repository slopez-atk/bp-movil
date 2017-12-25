import React from 'react';
import {List, ListItem} from 'material-ui/List';
import Subheader from 'material-ui/Subheader';
import Paper from 'material-ui/Paper';

import ImageFilter1 from 'material-ui/svg-icons/image/filter-1';
import ImageFilter2 from 'material-ui/svg-icons/image/filter-2';
import ImageFilter3 from 'material-ui/svg-icons/image/filter-3';
import ImageFilter4 from 'material-ui/svg-icons/image/filter-3';
import EditoMonetizationOn from 'material-ui/svg-icons/editor/monetization-on';
import EditoformatListNumbered from 'material-ui/svg-icons/editor/format-list-numbered';
import AlertWarning from 'material-ui/svg-icons/alert/warning';
import AvEqualizer from 'material-ui/svg-icons/av/equalizer';

const style = {
  height: 100,
  width: 100,
  margin: 20,
  textAlign: 'center',
  display: 'inline-block',
};

class PerMonthPercent extends React.Component{
  constructor(props){
    super(props);
    this.state = {
      first: [],
      second: [],
      third: [],
      fourth: []
    }
  }

  getData = () => {
    let SaldoFirst = parseFloat(this.props.first[0]);
    let SaldoSecond = parseFloat(this.props.second[0]);
    let SaldoThird = parseFloat(this.props.third[0]);
    let SaldoFourth = parseFloat(this.props.fourth[0]);

    let ProvisionFirst = parseFloat(this.props.first[2]);
    let ProvisionSecond = parseFloat(this.props.second[2]);
    let ProvisionThird = parseFloat(this.props.third[2]);
    let ProvisionFourth = parseFloat(this.props.fourth[2]);

    let totalSaldo = SaldoFirst + SaldoSecond + SaldoThird + SaldoFourth;
    let totalCantidad = this.props.first[1] + this.props.second[1] + this.props.third[1] + this.props.fourth[1];
    let totalProvision = ProvisionFirst + ProvisionSecond + ProvisionThird + ProvisionFourth;

    let PagoPorcentaje1 = ((10*totalSaldo)/100).toFixed(2);
    let PagoPorcentaje2 = ((40*totalSaldo)/100).toFixed(2);
    let PagoPorcentaje3 = ((40*totalSaldo)/100).toFixed(2);
    let PagoPorcentaje4 = ((10*totalSaldo)/100).toFixed(2);

    let first = [Number(((SaldoFirst * 100)/totalSaldo).toFixed(2)),Number(((this.props.first[1] * 100)/totalCantidad).toFixed(2)),Number(((ProvisionFirst * 100)/totalProvision).toFixed(2)),PagoPorcentaje1];
    let second = [Number(((SaldoSecond * 100)/totalSaldo).toFixed(2)),Number(((this.props.second[1] * 100)/totalCantidad).toFixed(2)), Number(((ProvisionSecond * 100)/totalProvision).toFixed(2)),PagoPorcentaje2];
    let third = [Number(((SaldoThird * 100)/totalSaldo).toFixed(2)),Number(((this.props.third[1] * 100)/totalCantidad).toFixed(2)), Number(((ProvisionThird * 100)/totalProvision).toFixed(2)),PagoPorcentaje3];
    let fourth = [Number(((SaldoFourth * 100)/totalSaldo).toFixed(2)),Number(((this.props.fourth[1] * 100)/totalCantidad).toFixed(2)), Number(((ProvisionFourth * 100)/totalProvision).toFixed(2)),PagoPorcentaje4];


    this.setState({
      first: first,
      second: second,
      third: third,
      fourth: fourth
    })
  };

  componentDidMount(){
    this.getData()
  }

  render(){
    return(
      <div>
        <div className="col-xs-6 col-md-3">
          <Paper zDepth={3}>
            <h4 style={{paddingTop:'1em'}}>Semana 1</h4>
            <List style={{textAlign:'left'}}>
              <Subheader>Porcentajes</Subheader>
              <ListItem primaryText={"Saldo: " + this.state.first[0] +" %"}  leftIcon={<EditoMonetizationOn/>} />
              <ListItem primaryText={"Cantidad: " + this.state.first[1] + " %"} leftIcon={<EditoformatListNumbered/>} />
              <ListItem primaryText={"Provisión: " + this.state.first[2] + " %"} leftIcon={<AlertWarning/>} />
              <ListItem primaryText={"Meta: " + this.state.first[3]} leftIcon={<AvEqualizer/>} />
            </List>
          </Paper>
        </div>

        <div className="col-xs-6 col-md-3">
          <Paper zDepth={3}>
            <h4 style={{paddingTop:'1em'}}>Semana 2</h4>
            <List style={{textAlign:'left'}}>
              <Subheader>Porcentajes</Subheader>
              <ListItem primaryText={"Saldo: " + this.state.second[0] +" %"}  leftIcon={<EditoMonetizationOn/>} />
              <ListItem primaryText={"Cantidad: " + this.state.second[1] + " %"} leftIcon={<EditoformatListNumbered/>} />
              <ListItem primaryText={"Provisión: " + this.state.second[2] + " %"} leftIcon={<AlertWarning/>} />
              <ListItem primaryText={"Meta: " + this.state.second[3]} leftIcon={<AvEqualizer/>} />
            </List>
          </Paper>
        </div>

        <div className="col-xs-6 col-md-3">
          <Paper zDepth={3}>
            <h4 style={{paddingTop:'1em'}}>Semana 3</h4>
            <List style={{textAlign:'left'}}>
              <Subheader>Porcentajes</Subheader>
              <ListItem primaryText={"Saldo: " + this.state.third[0] +" %"}  leftIcon={<EditoMonetizationOn/>} />
              <ListItem primaryText={"Cantidad: " + this.state.third[1] + " %"} leftIcon={<EditoformatListNumbered/>} />
              <ListItem primaryText={"Provisión: " + this.state.third[2] + " %"} leftIcon={<AlertWarning/>} />
              <ListItem primaryText={"Meta: " + this.state.third[3]} leftIcon={<AvEqualizer/>} />
            </List>
          </Paper>
        </div>

        <div className="col-xs-6 col-md-3">
          <Paper zDepth={3}>
            <h4 style={{paddingTop:'1em'}}>Semana 4</h4>
            <List style={{textAlign:'left'}}>
              <Subheader>Porcentajes</Subheader>
              <ListItem primaryText={"Saldo: " + this.state.fourth[0] +" %"}  leftIcon={<EditoMonetizationOn/>} />
              <ListItem primaryText={"Cantidad: " + this.state.fourth[1] + " %"} leftIcon={<EditoformatListNumbered/>} />
              <ListItem primaryText={"Provisión: " + this.state.fourth[2] + " %"} leftIcon={<AlertWarning/>} />
              <ListItem primaryText={"Meta: " + this.state.fourth[3]} leftIcon={<AvEqualizer/>} />
            </List>
          </Paper>
        </div>
      </div>
    );
  }
}

export default PerMonthPercent;