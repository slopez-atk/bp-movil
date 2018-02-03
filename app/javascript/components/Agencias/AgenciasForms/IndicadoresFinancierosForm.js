import React from 'react';
import ReactDOM from 'react-dom';
import {muiTheme} from '../muiThemeBase';


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






class IndicadoresFinancierosForm extends React.Component{

  constructor(props){
    super(props);
    this.state = {
      agencia: '',
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
              </div>

              <div>
                <FormsySelect
                  style={{textAlign: 'left'}}
                  required
                  floatingLabelText="Escoge una agencia"
                  floatingLabelStyle={{color: muiTheme.palette.primary1Color}}
                  name="agencia"
                  onChange={this.syncAgencia}>
                  <MenuItem value={'todos'} primaryText="Todos" />
                  <MenuItem value={'1'} primaryText="Matriz" />
                  <MenuItem value={'5'} primaryText="La Merced" />
                  <MenuItem value={'3'} primaryText="Cuenca del Lago San Pablo" />
                  <MenuItem value={'2'} primaryText="Cuenca del Rio Mira" />
                  <MenuItem value={'7'} primaryText="Economia Solidaria" />
                  <MenuItem value={'9'} primaryText="Frontera Norte" />
                  <MenuItem value={'8'} primaryText="Servimóvil" />
                  <MenuItem value={'6'} primaryText="Valle Fertil" />
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

export default IndicadoresFinancierosForm;