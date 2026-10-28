import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { CardProduct } from '../../components/card-product/card-product';
import { HeroBanner } from '../../components/hero-banner/hero-banner';

@Component({
  imports: [CardProduct, HeroBanner, RouterLink],
  selector: 'app-home-page',
  templateUrl: './home-page.html',
})
export class HomePage {}
