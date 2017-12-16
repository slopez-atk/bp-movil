import React from 'react';
import {Card, CardTitle, CardText, CardActions, CardHeader} from 'material-ui/Card';
import RaisedButton from 'material-ui/RaisedButton';
import TableDates from "./TableDates";
import {List, ListItem} from 'material-ui/List';
import Subheader from 'material-ui/Subheader';
import PerMonthPercent from './PerMonthPercent';

//Paleta de Colores
import palette from '../Palette';

// Iconos
import EditoMonetizationOn from 'material-ui/svg-icons/editor/monetization-on';
import EditoformatListNumbered from 'material-ui/svg-icons/editor/format-list-numbered';
import ImageFilter1 from 'material-ui/svg-icons/image/filter-1';
import ImageFilter2 from 'material-ui/svg-icons/image/filter-2';
import ImageFilter3 from 'material-ui/svg-icons/image/filter-3';
import ImageFilter4 from 'material-ui/svg-icons/image/filter-3';
import ActionTimeline from 'material-ui/svg-icons/action/timeline';
import AlertWarning from 'material-ui/svg-icons/alert/warning';



class PerMonth extends  React.Component{

  constructor(props){
    super(props);
  }

  getData(data){
    let saldo = 0;
    let contador = 0;
    let provision = 0;
    for(let i=0; i < data.length; i++){
      saldo += parseFloat(data[i]["saldo"]);
      provision += parseFloat(data[i]["provision"]);
      contador = contador + 1;
    }
    return [saldo.toFixed(2),contador,provision.toFixed(2)]
  }


  render(){
    let first = this.getData(this.props.firstWeek);
    let second = this.getData(this.props.secondWeek);
    let third = this.getData(this.props.thirdWeek);
    let fourth = this.getData(this.props.fourthWeek);

    return(
      <div className="top-space">
        <div className="col-xs-12 col-md-11">
          <h5 style={{color:palette.palette.accent1Color, paddingTop: '1em'}}>
            <ActionTimeline style={{color:palette.palette.accent1Color, marginRight: '19px'}}/>
            Resumen de cartera por vencer en porcentajes
          </h5>
          <PerMonthPercent first={first} second={second} third={third} fourth={fourth}/>
        </div>


        <div className="col-xs-12 col-md-11">
          <Card>
            <h5 style={{color:palette.palette.accent1Color, paddingTop: '1em'}}>
              <ImageFilter1 style={{color:palette.palette.accent1Color, marginRight: '19px'}}/>
              {"Primera semana del " + this.props.firstArrayDates[0] + " al " +  this.props.firstArrayDates[this.props.firstArrayDates.length -1]}
            </h5>
            <div className="row">
              <CardText style={{'textAlign':'left', maxWidth: '100%'}}>
                <div className="col-xs-12 col-md-3">
                  <List>
                    <Subheader>Datos Totales</Subheader>
                    <ListItem primaryText={"Saldo: " + first[0]}  leftIcon={<EditoMonetizationOn/>} />
                    <ListItem primaryText={"Cantidad: " + first[1]} leftIcon={<EditoformatListNumbered/>} />
                    <ListItem primaryText={"Provisión: " + first[2]} leftIcon={<AlertWarning/>} />
                  </List>
                </div>
                <div className="col-xs-12 col-md-9">
                  <TableDates DataWeek={ this.props.firstDataWeek } ArrayDates={ this.props.firstArrayDates }/>
                </div>
              </CardText>
            </div>
            <CardActions style={{'textAlign':'right'}}>
              <RaisedButton secondary={true} label="Ver Creditos" onClick={ () => this.props.onClick(this.props.firstWeek) }/>
            </CardActions>
          </Card>
        </div>

        <div className="col-xs-12 col-md-11 top-space">
          <Card>
            <h5 style={{color:palette.palette.accent1Color , paddingTop: '1em'}}>
              <ImageFilter2 style={{color:palette.palette.accent1Color, marginRight: '19px'}}/>
              {"Segunda semana del " + this.props.secondArrayDates[0] + " al " +  this.props.secondArrayDates[this.props.secondArrayDates.length -1]}
            </h5>
            <div className="row">
              <CardText style={{'textAlign':'left', maxWidth: '100%'}}>
                <div className="col-xs-12 col-md-3">
                  <List>
                    <Subheader>Datos Totales</Subheader>
                    <ListItem primaryText={"Saldo: " + second[0]}  leftIcon={<EditoMonetizationOn/>} />
                    <ListItem primaryText={"Cantidad: " + second[1]} leftIcon={<EditoformatListNumbered/>} />
                    <ListItem primaryText={"Provisión: " + second[2]} leftIcon={<AlertWarning/>} />
                  </List>
                </div>
                <div className="col-xs-12 col-md-9">
                  <TableDates DataWeek={ this.props.secondDataWeek } ArrayDates={ this.props.secondArrayDates }/>
                </div>
              </CardText>
            </div>
            <CardActions style={{'textAlign':'right'}}>
              <RaisedButton secondary={true} label="Ver Creditos" onClick={ () => this.props.onClick(this.props.secondWeek) }/>
            </CardActions>
          </Card>
        </div>

        <div className="col-xs-12 col-md-11 top-space">
          <Card>
            <h5 style={{color:palette.palette.accent1Color, paddingTop: '1em'}}>
              <ImageFilter3 style={{color:palette.palette.accent1Color, marginRight: '19px'}}/>
              {"Tercera semana del " + this.props.thirdArrayDates[0] + " al " +  this.props.thirdArrayDates[this.props.thirdArrayDates.length -1]}
            </h5>
            <div className="row">
              <CardText style={{'textAlign':'left', maxWidth: '100%'}}>
                <div className="col-xs-12 col-md-3">
                  <List>
                    <Subheader>Datos Totales</Subheader>
                    <ListItem primaryText={"Saldo: " + third[0]}  leftIcon={<EditoMonetizationOn/>} />
                    <ListItem primaryText={"Cantidad: " + third[1]} leftIcon={<EditoformatListNumbered/>} />
                    <ListItem primaryText={"Provisión: " + third[2]} leftIcon={<AlertWarning/>} />
                  </List>
                </div>
                <div className="col-xs-12 col-md-9">
                  <TableDates DataWeek={ this.props.thirdDataWeek } ArrayDates={ this.props.thirdArrayDates }/>
                </div>
              </CardText>
            </div>
            <CardActions style={{'textAlign':'right'}}>
              <RaisedButton secondary={true} label="Ver Creditos" onClick={ () => this.props.onClick(this.props.thirdWeek) }/>
            </CardActions>
          </Card>
        </div>

        <div className="col-xs-12 col-md-11 top-space">
          <Card>
            <h5 style={{color:palette.palette.accent1Color, paddingTop: '1em'}}>
              <ImageFilter4 style={{color:palette.palette.accent1Color, marginRight: '19px'}}/>
              {"Cuarta semana del " + this.props.fourthArrayDates[0] + " al " +  this.props.fourthArrayDates[this.props.fourthArrayDates.length -1]}
            </h5>
            <div className="row">
              <CardText style={{'textAlign':'left', maxWidth: '100%'}}>
                <div className="col-xs-12 col-md-3">
                  <List>
                    <Subheader>Datos Totales</Subheader>
                    <ListItem primaryText={"Saldo: " + fourth[0]}  leftIcon={<EditoMonetizationOn/>} />
                    <ListItem primaryText={"Cantidad: " + fourth[1]} leftIcon={<EditoformatListNumbered/>} />
                    <ListItem primaryText={"Provisión: " + fourth[2]} leftIcon={<AlertWarning/>} />
                  </List>
                </div>
                <div className="col-xs-12 col-md-9">
                  <TableDates DataWeek={ this.props.fourthDataWeek } ArrayDates={ this.props.fourthArrayDates }/>
                </div>
              </CardText>
            </div>
            <CardActions style={{'textAlign':'right'}}>
              <RaisedButton secondary={true} label="Ver Creditos" onClick={ () => this.props.onClick(this.props.fourthWeek) }/>
            </CardActions>
          </Card>
        </div>
      </div>
    );
  }
}

export default PerMonth;