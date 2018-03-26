import React from 'react';
import ActionAndroid from 'material-ui/svg-icons/action/android';
import ActionDelete from 'material-ui/svg-icons/action/delete';
import FlatButton from 'material-ui/FlatButton';
import reqwest from 'reqwest';
import {
  Table,
  TableBody,
  TableHeader,
  TableHeaderColumn,
  TableRow,
  TableRowColumn,
} from 'material-ui/Table';

class PlanificationList extends React.Component {
  constructor(props){
    super(props);
    this.state = {
      data: this.props.data
    }
  }

  handleLocation = (id) => {
    let route = '/worker_planifications/' + id + '/edit';
    window.location = route;
  };

  handleDelete(id){
    reqwest({
      url: '/worker_planifications/'+ id + '.json',
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': this.props.authenticity_token
      }
    }).then(planificacions => {
      this.props.onClick(planificacions);
      this.setState({
        data: planificacions
      })
    })
  }

  componentWillReceiveProps(props){
    this.setState({
      data: props.data
    })
  }

  getBody(data){
    return data.map(item => {
      return(
        <TableRow>
          <TableRowColumn>{item.fullname}</TableRowColumn>
          <TableRowColumn>{item.start_date}</TableRowColumn>
          <TableRowColumn>{item.end_date}</TableRowColumn>
          <TableRowColumn>
            <FlatButton
              label="Editar"
              labelPosition="before"
              primary={true}
              icon={<ActionAndroid />}
              onClick={() => this.handleLocation(item.id)}
            />
          </TableRowColumn>
          <TableRowColumn>
            <FlatButton
              label="Eliminar"
              labelPosition="before"
              secondary
              icon={<ActionDelete />}
              onClick={() => this.handleDelete(item.id)}
            />
          </TableRowColumn>
        </TableRow>
      )
    })
  }

  render(){
    return(
      <div className="row center-xs big-top-space">
        <div className="col-xs-12 col-md-7">
          <Table
            fixedHeader = { true }
            fixedFooter = { true }
            selectable = { false }
            multiSelectable ={ false }
          >
            <TableHeader
              displaySelectAll= {false}
              adjustForCheckbox= {true}
              enableSelectAll= {false}
            >
              <TableRow>
                <TableHeaderColumn>Nombre</TableHeaderColumn>
                <TableHeaderColumn>Dia Incio</TableHeaderColumn>
                <TableHeaderColumn>Dia Fin</TableHeaderColumn>
                <TableHeaderColumn>Acciones</TableHeaderColumn>
              </TableRow>
            </TableHeader>
            <TableBody
              displayRowCheckbox={false}
              showRowHover={true}
            >
              {this.getBody( this.state.data )}
            </TableBody>
          </Table>
        </div>
      </div>
    )
  }
}

export default PlanificationList;