import React from 'react';
import ReactDOM from 'react-dom';
import moment from 'moment';


// Material ui
import getMuiTheme from 'material-ui/styles/getMuiTheme';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import RaisedButton from 'material-ui/RaisedButton';
import MenuItem from 'material-ui/MenuItem';
import Paper from 'material-ui/Paper';
import {RadioButton, RadioButtonGroup} from 'material-ui/RadioButton';

// Formsy
import { FormsyDate } from 'formsy-material-ui';
import { FormsySelect } from 'formsy-material-ui';
import Formsy from 'formsy-react';
import FormsyText from 'formsy-material-ui/lib/FormsyText';

const muiTheme = getMuiTheme({
  palette: {
    primary1Color: "#3F51B5",
    accent1Color: "#FFC107",
    textColor: '#34495e'
  }
});




class CreditosVencidosForm extends React.Component{

  constructor(props){
    super(props);
    this.state = {
      fechaInicio: '',
      fechaFin: '',
      diaInicio: 0,
      diaFin: 0,
      tipoReporte: 'agencia',
      canSubmit: false
    }
  }

  submit(){
    ReactDOM.findDOMNode(this.refs.form).submit();
  }

  enableSubmitButton(){
    this.setState({
      canSubmit: true
    })
  }

  disableSubmitButton(){
    this.setState({
      canSubmit: false
    })
  }

  syncFechas(event, date, fieldName){
    let value = moment(date).format('DD-MM-YYYY');
    let jsonState = {};
    jsonState[fieldName] = value;
    this.setState(jsonState)
  }

  syncDiaInicio = (event, value) => {
    this.setState({
      diaInicio: value
    });
  };

  syncDiaFin = (event, value) => this.setState({
    diaFin: value
  });

  render(){
    return(
      <MuiThemeProvider muiTheme={getMuiTheme(muiTheme)}>
        <div>
          <Paper zDepth={3} rounded={true} className="padding top-space">
            <h5 style={{color: muiTheme.palette.accent1Color}}>{ this.props.title }</h5>
            <Formsy.Form
              onValid={()=> this.enableSubmitButton()}
              onValidSubmit={()=> this.submit()}
              onInvalid={ ()=> this.disableSubmitButton()}
              action={ this.props.url }
              method="post"
              ref="form">
              <div>
                <input type="hidden" name="authenticity_token" value={this.props.authenticity_token} readOnly={true} />
                <input type="hidden" name="diaInicio" value={this.state.diaInicio} readOnly={true} />
                <input type="hidden" name="diaFin" value={this.state.diaFin} readOnly={true} />
              </div>

              <div>
                <FormsyText
                  floatingLabelStyle={{color: muiTheme.palette.primary1Color}}
                  floatingLabelText="Desde"
                  required
                  name="diaInicio"
                  type="number"
                  validations="isNumeric"
                  onChange={ (event, value) => this.syncDiaInicio(event, value) }
                  validationError="Introduce solo numeros"/>
              </div>
              <div>
                <FormsyText
                  floatingLabelStyle={{color: muiTheme.palette.primary1Color}}
                  floatingLabelText="Hasta"
                  required
                  name="diaFin"
                  type="number"
                  validations="isNumeric"
                  onChange={ (event, value) => this.syncDiaFin(event, value) }
                  validationError="Introduce solo numeros"/>
              </div>
              <div className="row">
                <div className="col-xs-7 col-xs-offset-2">
                  <RadioButtonGroup name="tipoReporte" defaultSelected="agencia">
                    <RadioButton
                      value="agencia"
                      label="Reporte por agencia"
                      style={{marginTop: 10}}
                    />
                    <RadioButton
                      value="asesor"
                      label="Reporte por asesor"
                      style={{marginTop: 10, marginBottom: 10}}
                    />
                    <RadioButton
                      value="grupo_credito"
                      label="Reporte por grupo credito"
                      style={{marginTop: 10, marginBottom: 10}}
                    />
                  </RadioButtonGroup>
                </div>
              </div>
              <div>
                <RaisedButton
                  primary={true}
                  type="submit"
                  label="Consultar"
                  disabled={ !this.state.canSubmit }
                  labelColor="#ffffff"
                  ref="submitButton"
                />
              </div>
            </Formsy.Form>
          </Paper>
        </div>
      </MuiThemeProvider>
    );
  }
}

export default CreditosVencidosForm;