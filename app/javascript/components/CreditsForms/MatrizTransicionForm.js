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


class MatrizTransicionForm extends React.Component{

  constructor(props){
    super(props);
    this.state = {
      agencia: '',
      asesor: '',
      fechaInicio: '',
      fechaFin: '',
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

  syncAgencia = (event, value, index) => {
    this.setState({
      agencia: value
    });
  };

  syncFechas(event, date, fieldName){
    let value = moment(date).format('DD-MM-YYYY');
    let jsonState = {};
    jsonState[fieldName] = value;
    this.setState(jsonState)
  };

  syncAsesor = (event, value, index) => this.setState({
    asesor: value
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
                <input type="hidden" name="agencia" value={this.state.agencia} readOnly={true} />
                <input type="hidden" name="asesor" value={this.state.asesor} readOnly={true} />
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
                  floatingLabelText="Fecha de fin"/>
              </div>

              <div>
                <FormsySelect
                  style={{textAlign: 'left'}}
                  required
                  floatingLabelText="Escoge una agencia"
                  floatingLabelStyle={{color: muiTheme.palette.primary1Color}}
                  name="agencia"
                  onChange={this.syncAgencia}>
                  <MenuItem value={' '} primaryText="Todos" />
                  <MenuItem value={'Matriz'} primaryText="Matriz" />
                  <MenuItem value={'La Merced'} primaryText="La Merced" />
                  <MenuItem value={'Cuenca del Lago San Pablo'} primaryText="Cuenca del Lago San Pablo" />
                  <MenuItem value={'Cuenca del Rio Mira'} primaryText="Cuenca del Rio Mira" />
                  <MenuItem value={'Economia Solidaria'} primaryText="Economia Solidaria" />
                  <MenuItem value={'Frontera Norte'} primaryText="Frontera Norte" />
                  <MenuItem value={'Servimóvil'} primaryText="Servimóvil" />
                  <MenuItem value={'Valle Fertil'} primaryText="Valle Fertil" />
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
                  <MenuItem value={' '} primaryText="Todos" />
                  <MenuItem value={'PAREDES VICTORIA'} primaryText="PAREDES VICTORIA" />
                  <MenuItem value={'TERAN MARITZA'} primaryText="TERAN MARITZA" />
                  <MenuItem value={'RODRIGUEZ WILLIAM'} primaryText="RODRIGUEZ WILLIAM" />
                  <MenuItem value={'CHANDI VERONICA'} primaryText="CHANDI VERONICA" />
                  <MenuItem value={'SANCHEZ ANDREA'} primaryText="SANCHEZ ANDREA" />
                  <MenuItem value={'ALARCON JUAN CARLOS'} primaryText="ALARCON JUAN CARLOS" />
                  <MenuItem value={'CHAMORRO ANDRES'} primaryText="CHAMORRO ANDRES" />
                  <MenuItem value={'RODRIGUEZ JORGE'} primaryText="RODRIGUEZ JORGE" />
                  <MenuItem value={'PAZMINO MARCELIA'} primaryText="PAZMINO MARCELIA" />
                  <MenuItem value={'DUQUE GABRIELA'} primaryText="DUQUE GABRIELA" />
                  <MenuItem value={'DELGADO CRISTINA'} primaryText="DELGADO CRISTINA" />
                  <MenuItem value={'CHANDI SILVIA'} primaryText="CHANDI SILVIA" />
                  <MenuItem value={'BENAVIDES ROMEL'} primaryText="BENAVIDES ROMEL" />
                  <MenuItem value={'CHAPI BYRON'} primaryText="CHAPI BYRON" />
                  <MenuItem value={'INSUASTI SANDRA'} primaryText="INSUASTI SANDRA" />
                  <MenuItem value={'CATUCUAGO MARINA'} primaryText="CATUCUAGO MARINA" />
                  <MenuItem value={'HIDROBO STIWAR'} primaryText="HIDROBO STIWAR" />
                  <MenuItem value={'ANDRADE EDISON'} primaryText="ANDRADE EDISON" />
                  <MenuItem value={'ALMEIDA FRANCISCO'} primaryText="ALMEIDA FRANCISCO" />
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

export default MatrizTransicionForm;