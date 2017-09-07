import React from 'react';
import Formsy from 'formsy-react';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import FormsyText from 'formsy-material-ui/lib/FormsyText';
import RaisedButton from 'material-ui/RaisedButton';
import {Base, styles} from "./base";
import reqwest from 'reqwest';

export class Singup extends Base {

  submit() {
    reqwest({
      url: '/users.json',
      method: 'POST',
      data: {
        user: {
          email: this.state.email,
          password: this.state.password,
          passwordConfirmation: this.state.passwordConfirmation
        }
      },
      headers: {
        'X-CSRF-Token': window.AppCacmu.token
      }
    }).then(data => {
      this.reload()
    }).catch(err => {
      this.handleError(err);
    });
  }

  handleError(err){
    const jsonError = JSON.parse(err.response);
    const errors = jsonError.errors;
    let errorResponse = [];

    for(let key in errors){
      errorResponse.push(<li>{errors[key]}</li>);
    }
    this.setState({
      error: errorResponse
    })
  }

  render(){
    return (
      <MuiThemeProvider>
        <Formsy.Form onValid={ ()=> this.enableSubmitButton() }
                     onInvalid={ ()=> this.disableSubmitButton() }
                     onValidSubmit={ ()=> this.submit() }>
          <ul>{this.state.error}</ul>
          <div>
            <FormsyText
              onChange={ (e)=> this.syncFiled(e, "email")}
              name="email"
              required
              validations="isEmail"
              validationError="Introduce un correo electrónico válido"
              floatingLabelText="Correo electrónico"
              floatingLabelFocusStyle={styles.floatingLabelFocusStyle}
              underlineFocusStyle={styles.underlineStyle}
            />
          </div>

          <div>
            <FormsyText
              onChange={ (e)=> this.syncFiled(e, "password")}
              name="password"
              required
              type="password"
              floatingLabelText="Contraseña"
              floatingLabelFocusStyle={styles.floatingLabelFocusStyle}
              underlineFocusStyle={styles.underlineStyle}
            />
          </div>

          <div>
            <FormsyText
              onChange={ (e)=> this.syncFiled(e, "passwordConfirmation")}
              name="passwordConfirmation"
              required
              type="password"
              floatingLabelText="Confirmar contraseña"
              floatingLabelFocusStyle={styles.floatingLabelFocusStyle}
              underlineFocusStyle={styles.underlineStyle}
            />
          </div>

          <div>
            <RaisedButton
              style={styles.buttonStyle}
              type="submit"
              label="Crear cuenta"
              disabled={ !this.state.canSubmit }
              backgroundColor={ styles.red }
              labelColor="#ffffff"
            />
          </div>
        </Formsy.Form>
      </MuiThemeProvider>
    );
  }
}