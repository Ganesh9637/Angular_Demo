import { TestBed } from '@angular/core/testing';
import { HttpRequest } from '@angular/common/http';
import { tokenInterceptor } from './token.interceptor';
import { JwtService } from '../auth/services/jwt.service';
import { of } from 'rxjs';

describe('TokenInterceptor', () => {
  let jwtServiceSpy: jasmine.SpyObj<JwtService>;

  beforeEach(() => {
    jwtServiceSpy = jasmine.createSpyObj('JwtService', ['getToken']);
    
    TestBed.configureTestingModule({
      providers: [
        { provide: JwtService, useValue: jwtServiceSpy }
      ]
    });
  });

  it('should add Authorization header when token exists', () => {
    const token = 'test-token';
    jwtServiceSpy.getToken.and.returnValue(token);
    
    const next = jasmine.createSpy('next').and.returnValue(of({}));
    const req = new HttpRequest('GET', '/articles');
    
    TestBed.runInInjectionContext(() => {
      tokenInterceptor(req, next);
    });
    
    expect(next).toHaveBeenCalled();
    const interceptedRequest = next.calls.mostRecent().args[0];
    expect(interceptedRequest.headers.get('Authorization')).toBe(`Token ${token}`);
  });

  it('should not add Authorization header when token does not exist', () => {
    jwtServiceSpy.getToken.and.returnValue(null);
    
    const next = jasmine.createSpy('next').and.returnValue(of({}));
    const req = new HttpRequest('GET', '/articles');
    
    TestBed.runInInjectionContext(() => {
      tokenInterceptor(req, next);
    });
    
    expect(next).toHaveBeenCalled();
    const interceptedRequest = next.calls.mostRecent().args[0];
    expect(interceptedRequest.headers.has('Authorization')).toBeFalse();
  });
});