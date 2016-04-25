import React, { Component } from 'react'
import { render } from 'react-dom'
import { Provider } from 'react-redux'

import AppContainer from './AppContainer'
import configureStore from '../store/configureStore'
import {attachNote} from '../actions/note'

const store = configureStore();

export default class Root extends React.Component {

    componentWillMount() {
	//console.log("Root componentWillMount() this.props.note=%o", this.props.note)
	store.dispatch(attachNote(this.props.note))
    }
    render() {
	return (
	    <Provider store={store}>
	      <AppContainer />
	    </Provider>
	)
    }
}
