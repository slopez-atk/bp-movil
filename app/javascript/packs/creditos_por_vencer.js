import React from 'react';
import WebpackerReact from 'webpacker-react';
import PerMonth from "../components/CreditosPorVencer/PerMonth";
import PerWeek from "../components/CreditosPorVencer/PerWeek";
import Snackbar from 'material-ui/Snackbar';


//Material ui
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

class CreditosPorVencer extends React.Component{

  constructor(props){
    super(props);
    this.state = {
      creditos: [],
      open: false
    };
    this.showWeek = this.showWeek.bind(this);
  }

  showWeek(data){
    this.setState({
      creditos: data
    });
    this.SnackhandleClick()
  }

  SnackhandleClick = () => {
    this.setState({
      open: true,
    });
  };

  SnackhandleRequestClose = () => {
    this.setState({
      open: false,
    });
  };

  render(){
    return(
      <MuiThemeProvider muiTheme={getMuiTheme(muiTheme)}>
        <div>
          <PerMonth
            firstWeek={ this.props.firstWeek }
            secondWeek={ this.props.secondWeek }
            thirdWeek={ this.props.thirdWeek }
            fourthWeek={ this.props.fourthWeek }
            firstDataWeek={ this.props.firstDataWeek }
            firstArrayDates={ this.props.firstArrayDates }
            secondDataWeek={ this.props.secondDataWeek }
            secondArrayDates={ this.props.secondArrayDates }
            thirdDataWeek= { this.props.thirdDataWeek }
            thirdArrayDates={ this.props.thirdArrayDates }
            fourthDataWeek={ this.props.fourthDataWeek }
            fourthArrayDates={ this.props.fourthArrayDates }
            onClick={ this.showWeek }/>
          <hr/>
          <div className="top-space">
            <PerWeek data={ this.state.creditos }/>
          </div>
          <div>
            <Snackbar
              open={this.state.open}
              message="Datos Cargados en la Tabla"
              autoHideDuration={4000}
              onRequestClose={this.SnackhandleRequestClose}
            />
          </div>
        </div>
      </MuiThemeProvider>
    );
  };
};

WebpackerReact.setup({CreditosPorVencer});