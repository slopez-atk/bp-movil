import React from 'react';
import WebpackerReact from 'webpacker-react';
import MatrizSaldos from '../components/MatrizTransicion/MatrizSaldos';
import ListCredits from '../components/MatrizTransicion/ListCredits';

//Material ui
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import getMuiTheme from 'material-ui/styles/getMuiTheme';
import {Tabs, Tab} from 'material-ui/Tabs';


const muiTheme = getMuiTheme({
  drawer: {
    color: '#FDD835'
  },
  appBar: {
    color: '#2E3092'
  },
  palette: {
    primary1Color: "#3F51B5",
    accent1Color: "#FFC107",
  }
});


class MatrizTransicion extends React.Component{

  constructor(props){
    super(props);
    this.state = {
      credits: []
    };
    this.getCredits = this.getCredits.bind(this);
  }

  getCredits(calificaciones){
    let c1 = calificaciones["calificacion1"];
    let c2 = calificaciones["calificacion2"];
    let data = this.props.data;
    if( data[c1] === undefined ){
      this.setState({
        credits: []
      })
    } else if (data[c1][c2] === undefined){
      this.setState({
        credits: []
      })
    } else {
      this.setState({
        credits: data[c1][c2]
      })
    }
  }
  render(){
    return(
      <MuiThemeProvider muiTheme={getMuiTheme(muiTheme)}>
        <div>
          <Tabs>
            <Tab label="Matriz de Saldos">
              <MatrizSaldos data={ this.props.saldos } matriz={ this.props.matriz }/>
            </Tab>

            <Tab label="Matriz de Cantidades">
              <MatrizSaldos data={ this.props.cantidades } matriz={ this.props.matriz }/>
            </Tab>

            <Tab label="Consultas">
              <ListCredits data={ this.state.credits } onClick={()=> this.getCredits }/>
            </Tab>
          </Tabs>
        </div>
      </MuiThemeProvider>
    );
  }
}

WebpackerReact.setup({MatrizTransicion});