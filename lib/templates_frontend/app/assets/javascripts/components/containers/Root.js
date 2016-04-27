import React, { Component } from 'react'
import { render } from 'react-dom'
import { Provider } from 'react-redux'

import AppConnector from './AppConnector'
import configureStore from '../store/configureStore'

const store = configureStore();

export class Root extends React.Component {

    componentWillMount() {
	//console.log("Root componentWillMount() this.props.note=%o", this.props.note)
	//store.dispatch(attachNote(this.props.note))
    }
    render() {
	return (
	    <Provider store={store}>
	      <AppConnector />
	    </Provider>
	)
    }
}
