import React from 'react';
import WebpackerReact from 'webpacker-react';
import BigCalendar from 'react-big-calendar-like-google';
import moment from 'moment';

import getMuiTheme from 'material-ui/styles/getMuiTheme';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import Paper from 'material-ui/Paper';
import PlanificacionesForm from "./planificaciones_form";
import PlanificationList from "./planification_list";

BigCalendar.setLocalizer(
  BigCalendar.momentLocalizer(moment)
);
let allViews = Object.keys(BigCalendar.Views).map(k => BigCalendar.Views[k]);

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


class CalendarPermissions extends React.Component {
  constructor(props){
    super(props);
    let eventos = this.props.eventos.map(event => {
      return {
        id: event.id,
        title: event.fullname,
        allDay: true,
        bgColor: '#dc143c',
        start: moment(event.start_date, "DD-MM-YYYY").toDate(),
        end: moment(event.end_date, "DD-MM-YYYY").toDate(),
      }
    });
    this.state = {
      permisos: eventos,
      eventos: this.props.eventos
    };
    this.updateEventos = this.updateEventos.bind(this);

  }

  updateEventos(events){
    this.setState({
      permisos: this.crearEventos(events),
      eventos: events
    })
  }

  crearEventos(events){
    return events.map(event => {
      return {
        id: event.id,
        title: event.fullname,
        allDay: true,
        bgColor: '#dc143c',
        start: moment(event.start_date, "DD-MM-YYYY").toDate(),
        end: moment(event.end_date, "DD-MM-YYYY").toDate(),
      }
    });
  }

  getBody(){
    if(this.props.display_extras === true){
      return(
        <div>
          <PlanificationList
            authenticity_token={this.props.authenticity_token}
            data = { this.state.eventos }
            onClick={ this.updateEventos }
          />

          <PlanificacionesForm
            authenticity_token={this.props.authenticity_token}
            worker_id={this.props.worker_id}
            onClick={ this.updateEventos }
          />
        </div>
      )
    } else {
      return(
        <div>

        </div>
      )
    }
  }

  render(){
    return(
      <MuiThemeProvider muiTheme={getMuiTheme(muiTheme)}>
        <div>

          <Paper zDepth={3} className="padding">
            <BigCalendar
              style={{height: '700px'}}
              events={this.state.permisos}
              views={allViews}
              step={60}
              defaultDate={new Date()}
            />
          </Paper>

          { this.getBody() }


        </div>
      </MuiThemeProvider>

    )
  }
}

WebpackerReact.setup({CalendarPermissions});

