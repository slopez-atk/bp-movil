import React from 'react';
import WebpackerReact from 'webpacker-react';

class Test extends React.Component{
  constructor(props){
    super(props)
  }

  render(){
    return(
      <div>
        <h1>Funciona!</h1>
      </div>
    )
  }
}
WebpackerReact.setup({Test});