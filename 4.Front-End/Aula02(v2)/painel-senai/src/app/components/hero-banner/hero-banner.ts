import { Component, OnDestroy, OnInit, signal } from '@angular/core';

type HeroSlide = {
  title: string;
  description: string;
  image: string;
  alt: string;
};

@Component({
  imports: [],
  selector: 'app-hero-banner',
  styleUrl: './hero-banner.css',
  templateUrl: './hero-banner.html',
})
export class HeroBanner implements OnInit, OnDestroy {
  readonly activeSlide = signal(0);
  readonly slides: HeroSlide[] = [
    {
      title: 'Aprenda na prática',
      description: 'Cursos SENAI para transformar conhecimento em oportunidades.',
      image:
        'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=1400&q=85',
      alt: 'Profissional trabalhando em um ambiente industrial',
    },
    {
      title: 'Prepare-se para a indústria',
      description: 'Desenvolva habilidades para os desafios do mercado.',
      image:
        'https://images.unsplash.com/photo-1565793298595-6a879b1d9492?auto=format&fit=crop&w=1400&q=85',
      alt: 'Máquinas em uma linha de produção industrial',
    },
    {
      title: 'Construa seu futuro',
      description: 'Conhecimento técnico para você avançar na carreira.',
      image:
        'https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?auto=format&fit=crop&w=1400&q=85',
      alt: 'Profissional usando equipamento de soldagem',
    },
  ];

  private sliderInterval?: ReturnType<typeof setInterval>;

  ngOnInit() {
	this.startAutoPlay();
  }

  ngOnDestroy() {
    if (this.sliderInterval) {
      clearInterval(this.sliderInterval);
    }
  }

  selectSlide(index: number) {
    this.activeSlide.set(index);
    this.startAutoPlay();
  }

  private nextSlide() {
    this.activeSlide.update((index) => (index + 1) % this.slides.length);
  }

  private startAutoPlay() {
    if (this.sliderInterval) {
      clearInterval(this.sliderInterval);
    }

    this.sliderInterval = setInterval(() => this.nextSlide(), 5000);
  }
}
