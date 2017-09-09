import React from 'react';
import Formsy from 'formsy-react';
import getMuiTheme from 'material-ui/styles/getMuiTheme';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import FormsyText from 'formsy-material-ui/lib/FormsyText';
import RaisedButton from 'material-ui/RaisedButton';
import reqwest from 'reqwest';
import { redA400, blueA400, pink500 } from 'material-ui/styles/colors';

const styles = {
  buttonStyle: {
    marginTop: '0.5em',
    marginBottom: '1.3em'
  },
  displayNoneStyle: {
    display: 'none'
  }
};

export class LawyerForm extends React.Component{
  constructor(props){
    super(props);
    this.state = {
      error: '',
      name: '',
      lastname: '',
      phone: ''
    }
  }

  submit(){
    reqwest({
      url: '/lawyers.json',
      method: 'POST',
      data: {
        lawyer: {
          name: this.state.name,
          lastname: this.state.lastname,
          phone: this.state.phone
        }
      },
      headers: {
        'X-CSRF-Token': window.AppCacmu.token
      }
    }).then(data => {
      this.props.add(data);
      this.refs.name_content.resetValue();
      this.refs.lastname_content.resetValue();
      this.refs.phone_content.resetValue();
    }).catch(err => {

    })
  }

  syncField(ev, fieldName){
    let element = ev.target;
    let value = element.value;
    let json = [];

    json[fieldName] = value;
    this.setState(json)
  }

  render () {
    return (
      <MuiThemeProvider>
        <Formsy.Form onValidSubmit={ ()=> this.submit()}>
          <div>
            <FormsyText
              name="lawyer[name]"
              required
              floatingLabelText="Nombre del abogado"
              onChange={ (e)=> this.syncField(e, "name")}
              ref="name_content"
            />
          </div>

          <div>
            <FormsyText
              name="lawyer[lastname]"
              required
              floatingLabelText="Apellido del abogado"
              onChange={ (e)=> this.syncField(e, "lastname")}
              ref="lastname_content"
            />
          </div>

          <div>
            <FormsyText
              name="lawyer[phone]"
              required
              floatingLabelText="Telefono del abogado"
              onChange={ (e)=> this.syncField(e, "phone")}
              ref="phone_content"
            />
          </div>

          <div>
            <RaisedButton
              type="submit"
              label="Ingresar abogado"
              backgroundColor={pink500}
              labelColor="#fff"
              style={styles.buttonStyle}/>
          </div>
        </Formsy.Form>
      </MuiThemeProvider>
    )
  }
}