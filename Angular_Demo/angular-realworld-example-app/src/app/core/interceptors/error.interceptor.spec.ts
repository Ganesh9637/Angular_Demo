import { TestBed } from '@angular/core/testing';
import { HttpErrorResponse, HttpRequest } from '@angular/common/http';
import { errorInterceptor } from './error.interceptor';
import { of, throwError } from 'rxjs';

describe('ErrorInterceptor', () => {
  it('should pass through non-error responses', (done) => {
    const next = jasmine.createSpy('next').and.returnValue(of('success'));
    const req = new HttpRequest('GET', '/articles');
    
    errorInterceptor(req, next).subscribe({
      next: (value) => {
        expect(value).toBe('success');
        done();
      },
      error: () => fail('Should not error')
    });
  });

  it('should transform error responses', (done) => {
    const errorResponse = new HttpErrorResponse({
      error: { errors: { 'some-field': ['error message'] } },
      status: 422,
      statusText: 'Unprocessable Entity'
    });
    
    const next = jasmine.createSpy('next').and.returnValue(throwError(() => errorResponse));
    const req = new HttpRequest('GET', '/articles');
    
    errorInterceptor(req, next).subscribe({
      next: () => fail('Should error'),
      error: (error) => {
        expect(error).toEqual({ errors: { 'some-field': ['error message'] } });
        done();
      }
    });
  });
});