import { Component, signal } from '@angular/core';
import { Carousel } from './carousel/carousel';
import { Card } from './card/card';
import { Footer } from './footer/footer';

@Component({
  imports: [Carousel, Card, Footer],
  selector: 'app-root',
  styleUrl: './app.css',
  templateUrl: './app.html',
})
export class App {
  protected readonly title = signal('revisao-app');
}
