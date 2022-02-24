import React, { Component } from 'react';
import { Carousel, Button } from 'react-bootstrap';
import "./touchwood.css";

import { getLocation, submit_click } from '../kstream/kstream';

const LOCALSTORAGE_ITEM = "TouchwoodState";
const random_pick = (items) => items[items.length * Math.random() | 0];

class TouchWood extends Component {
    constructor(props) {
        super(props);
        this.state = {
            lang: 'hk'
            , likes: []
        };

        this.handleLangBtn = this.handleLangBtn.bind(this);
        this.handleLikeBtn = this.handleLikeBtn.bind(this);
    }

    componentDidMount() {
        // Submit Geolocation
        getLocation();

        var touchwoodState = JSON.parse(localStorage.getItem(LOCALSTORAGE_ITEM));
        if (touchwoodState !== null) {
            this.setState({
                lang: touchwoodState['lang']
                , likes: touchwoodState['likes']
            });
        }
    }

    handleLangBtn(_event) {
        _event.preventDefault();
        var thisLang = this.state.lang;
        var newLang = (thisLang === 'hk')?'en':'hk';

        // Submit the clickstream
        submit_click("CLICK_LANG", newLang);

        this.setState({
            lang: newLang
        });
        var thisLikes = this.state.likes;
        this.saveStateToLocalStorage({
            lang: newLang
            , likes: thisLikes
        });
    }

    handleLikeBtn(_event, givenIdx) {
        _event.preventDefault();
        var thisLikes = this.state.likes;
        var likedBefore = thisLikes.includes(givenIdx);
        if (likedBefore) {
            thisLikes = thisLikes.filter(item => item !== givenIdx);

            // Submit the clickstream
            submit_click("UNLIKE_WOOD", givenIdx);            
        } else {            
            thisLikes.push(givenIdx);
            
            // Submit the clickstream
            submit_click("LIKE_WOOD", givenIdx);
        }
        this.setState({
            likes: thisLikes
        });        
        var thisLang = this.state.lang;
        this.saveStateToLocalStorage({
            lang: thisLang
            , likes: thisLikes
        });        
    }

    saveStateToLocalStorage(touchwoodState) {
        localStorage.setItem(LOCALSTORAGE_ITEM, JSON.stringify(touchwoodState));
    }

    renderLikeBtn(currentIdx) {
        return (this.state.likes.includes(currentIdx))?
        (            
            <Button variant="danger" onClick={(_event) => this.handleLikeBtn(_event, currentIdx)}><i className="bi bi-heart"></i></Button>
        ):
        (            
            <Button variant="outline-warning" onClick={(_event) => this.handleLikeBtn(_event, currentIdx)}><i className="bi bi-heart"></i></Button>
        );
    }

    render() {
        return (
<div className="slider-container">
    <span className="top-right-icon">
        <Button variant="success" onClick={ this.handleLangBtn }>{ (this.state.lang === "hk")?"HK":"EN" }</Button>
    </span>
<Carousel fade>
    {
        this.props.images.map((imageUrl, idx) =>
<Carousel.Item key={ "item" + idx }>
    <img
        className="carousel-image d-block w-100"
        src={imageUrl}
    />
    <Carousel.Caption>
        <h3>{ this.renderLikeBtn(idx) } Touchwood! &#x1f91e;</h3>
        <p className="quote-text">
{random_pick((this.state.lang === "hk")?this.props.hk_quotes:this.props.en_quotes)}            
        </p>
    </Carousel.Caption>
</Carousel.Item>
        )
    }
</Carousel>
</div>
        )
    }
}

export default TouchWood;