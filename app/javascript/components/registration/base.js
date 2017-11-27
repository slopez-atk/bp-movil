import React from 'react';
import { blueA400, redA400 } from 'material-ui/styles/colors';

export const styles = {
  buttonTop: {
    marginTop: '1em'
  },
  underlineStyle: {
    borderColor: '#ffce00'
  },
  floatingLabelFocusStyle: {
    color: '#ffce00'
  },
  leftSpace: {
    marginLeft: '1em'
  },
  red: redA400,
  gris: '#595753'
};

export class Base extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      canSubmit: true,
      email: '',
      password: '',
      passwordConfirmation: '',
      error: ''
    };
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

  reload () {
    window.location.href = window.location.href;
  }

  syncFiled(ev, fieldName){
    let element = ev.target;
    let value = element.value;
    let jsonState = {};
    jsonState[fieldName] = value;
    this.setState(jsonState)
  }
}