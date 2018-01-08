import React from "react";
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import getMuiTheme from 'material-ui/styles/getMuiTheme';
import IndicadoresTable from '../components/CreditsIndicadores/IndicadoresTable';

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
class CreditosIndicadores extends React.Component{
  constructor(props){
    super(props)
  }

  render(){
    return(
      <MuiThemeProvider muiTheme={getMuiTheme(muiTheme)}>
        <div>
          <div>
            <IndicadoresTable title={"Indicador de Genero"} data={ this.props.generos }/>
          </div>

          <div>
            <IndicadoresTable title={"Indicador de Sector"} data={ this.props.sectores }/>
          </div>

          <div>
            <IndicadoresTable title={"Indicador de Tipo de Credito"} data={ this.props.tipos_credito }/>
          </div>

          <div>
            <IndicadoresTable title={"Indicador de Origen de Recursos"} data={ this.props.origenes_recursos }/>
          </div>
        </div>
      </MuiThemeProvider>
    );
  }
}

WebpackerReact.setup({CreditosIndicadores});