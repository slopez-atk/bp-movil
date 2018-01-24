import React from "react";
import WebpackerReact from 'webpacker-react';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import getMuiTheme from 'material-ui/styles/getMuiTheme';
import IndicadoresTable from '../components/CreditsIndicadores/IndicadoresTable';

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

const styles = {
  headline: {
    fontSize: 24,
    paddingTop: 16,
    marginBottom: 12,
    fontWeight: 400,
  },
};
class CreditosIndicadores extends React.Component{
  constructor(props){
    super(props)
  }

  render(){
    return(
      <MuiThemeProvider muiTheme={getMuiTheme(muiTheme)}>
        <Tabs>
          <Tab label="Genero">
            <IndicadoresTable title={"Indicador de Genero"} data={ this.props.generos }/>
          </Tab>

          <Tab label="Sector">
            <IndicadoresTable title={"Indicador de Sector"} data={ this.props.sectores }/>
          </Tab>

          <Tab label="Tipo Credito">
            <IndicadoresTable title={"Indicador de Tipo de Credito"} data={ this.props.tipos_credito }/>
          </Tab>

          <Tab label="Origen Recursos">
            <IndicadoresTable title={"Indicador de Origen de Recursos"} data={ this.props.origenes_recursos }/>
          </Tab>

          <Tab label="Metodología">
            <IndicadoresTable title={"Indicador de Metodología"} data={ this.props.metodologias }/>
          </Tab>

          <Tab label="Instrucción">
            <IndicadoresTable title={"Indicador de Nivel de Instrucción"} data={ this.props.nivel_instrucciones }/>
          </Tab>

          <Tab label="Estado Civil">
            <IndicadoresTable title={"Indicador de Estado Civil"} data={ this.props.estados_civiles }/>
          </Tab>

          <Tab label="Edades">
            <IndicadoresTable title={"Indicador de Rango de Edades"} data={ this.props.rango_edades }/>
          </Tab>
        </Tabs>
      </MuiThemeProvider>
    );
  }
}

WebpackerReact.setup({CreditosIndicadores});