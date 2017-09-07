import React from 'react';
import WebpackerReact from 'webpacker-react'
import { Login } from '../components/registration/login';
import { Singup } from "../components/registration/singup";

class Registration extends React.Component {

  render() {
    return <Login/>
  }
}
WebpackerReact.setup({Registration});
