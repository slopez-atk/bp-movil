import React from 'react';
import ReactDOM from 'react-dom';
import moment from 'moment';


// Material ui
import getMuiTheme from 'material-ui/styles/getMuiTheme';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import RaisedButton from 'material-ui/RaisedButton';
import MenuItem from 'material-ui/MenuItem';
import Paper from 'material-ui/Paper';

// Formsy
import { FormsyDate } from 'formsy-material-ui';
import { FormsySelect } from 'formsy-material-ui';
import Formsy from 'formsy-react';

const muiTheme = getMuiTheme({
  palette: {
    primary1Color: "#3F51B5",
    accent1Color: "#FFC107",
    textColor: '#34495e'
  }
});


class CreditosPorVencerForm extends React.Component{

  constructor(props){
    super(props);
    this.state = {
      fechaInicio: 'vacio',
      fechaFin: '',
      agencia: '',
      asesor: '',
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

  syncAgencia = (event, value, index) => {
    this.setState({
      agencia: value
    });
  }

  syncAsesor = (event, value, index) => this.setState({
    asesor: value
  });

  render(){
    return(
      <MuiThemeProvider muiTheme={getMuiTheme(muiTheme)}>
        <div className="col-xs-12 col-md-5">
          <Paper zDepth={3} rounded={true} className="padding">
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
                <input type="hidden" name="agencia" value={this.state.agencia} readOnly={true} />
                <input type="hidden" name="asesor" value={this.state.asesor} readOnly={true} />
                <input type="hidden" name="fechaInicio" value={this.state.fechaInicio} readOnly={true} />
                <input type="hidden" name="fechaFin" value={this.state.fechaFin} readOnly={true} />
              </div>
              <div>
                <FormsyDate
                  floatingLabelStyle={{color: muiTheme.palette.primary1Color}}
                  onChange={ (ev, date)=> this.syncFechas(ev, date, 'fechaInicio') }
                  name="fecha1"
                  required
                  floatingLabelText="Fecha de Inicio"/>
              </div>
              <div>
                <FormsyDate
                  floatingLabelStyle={{color: muiTheme.palette.primary1Color}}
                  onChange={ (ev, date)=> this.syncFechas(ev, date, 'fechaFin') }
                  name="fecha2"
                  required
                  floatingLabelText="Fecha de Finalizacion"/>
              </div>
              <div>
                <FormsySelect
                  style={{textAlign: 'left'}}
                  required
                  floatingLabelText="Escoge una agencia"
                  floatingLabelStyle={{color: muiTheme.palette.primary1Color}}
                  name="agencia"
                  onChange={this.syncAgencia}>
                  <MenuItem value={'%%'} primaryText="Todos" />
                  <MenuItem value={'Matriz'} primaryText="Matriz" />
                  <MenuItem value={'La Merced'} primaryText="La Merced" />
                </FormsySelect>
              </div>
              <div>
                <FormsySelect
                  style={{textAlign: 'left'}}
                  required
                  floatingLabelText="Escoge un asesor"
                  floatingLabelStyle={{color: muiTheme.palette.primary1Color}}
                  name="asesor"
                  onChange={this.syncAsesor}>
                  <MenuItem value={'%%'} primaryText="Todos" />
                  <MenuItem value={'Valentina'} primaryText="Valentina" />
                  <MenuItem value={'Daniela'} primaryText="Daniela" />
                </FormsySelect>
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

export default CreditosPorVencerForm;