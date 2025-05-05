import { TestBed } from '@angular/core/testing';
import { HttpRequest } from '@angular/common/http';
import { apiInterceptor } from './api.interceptor';
import { environment } from '../../../environments/environment';
import { of } from 'rxjs';

describe('ApiInterceptor', () => {
  it('should prepend the API URL to the request URL', () => {
    const next = jasmine.createSpy('next').and.returnValue(of({}));
    const req = new HttpRequest('GET', '/articles');
    
    apiInterceptor(req, next);
    
    expect(next).toHaveBeenCalled();
    const interceptedRequest = next.calls.mostRecent().args[0];
    expect(interceptedRequest.url).toBe(`${environment.api_url}/articles`);
  });
});