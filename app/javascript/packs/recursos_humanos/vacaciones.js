import React from 'react';
import Paper from 'material-ui/Paper';
import WebpackerReact from 'webpacker-react';
import WorkersList from '../../components/RecursosHumanos/workers_list';


//Material Ui
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import getMuiTheme from 'material-ui/styles/getMuiTheme';


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
class Vacaciones extends React.Component {

  constructor(props){
    super(props);
    this.state = {
      lista_trabajadores: this.props.data
    }
  }

  render(){
    return(
      <MuiThemeProvider muiTheme={getMuiTheme(muiTheme)}>
        <div className="row center-xs top-space">
          <div className="col-xs-11 col-md-5">
            <Paper zdepth={3}>
              <WorkersList data={this.state.lista_trabajadores}/>
            </Paper>
          </div>
        </div>
      </MuiThemeProvider>
    );
  }
}
WebpackerReact.setup({Vacaciones});