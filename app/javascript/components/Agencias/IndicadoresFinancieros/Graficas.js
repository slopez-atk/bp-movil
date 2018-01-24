import React from 'react';
import { Bar } from 'react-chartjs-2';

class Graficas extends React.Component {
  constructor(props){
    super(props)
  }

  getData(){
    let data = {
      labels: ['Diciembre', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
      datasets: [
        {
          label: this.props.titulo,
          backgroundColor: 'rgba(255,99,132,0.2)',
          borderColor: 'rgba(255,99,132,1)',
          borderWidth: 1,
          hoverBackgroundColor: 'rgba(255,99,132,0.4)',
          hoverBorderColor: 'rgba(255,99,132,1)',
          data: this.props.data
        }
      ]
    }
    return data;
  }

  render(){
    return(
      <div>
        <Bar
          data={this.getData()}
          width={80}
          height={25}/>
      </div>
    );
  }
}

export default Graficas;