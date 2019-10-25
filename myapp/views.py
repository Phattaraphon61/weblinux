from django.shortcuts import render
from django.utils import encoding #smart_unicode
from urllib.parse import parse_qsl

from .models import Service
from datetime import date

# Create your views here.
def index(req):
    return render(req, 'myapp/index.html')
    # if req.method == 'POST':
    #     post = req.POST
    #     s = Service()
    #     s.icon = post['icon']
    #     s.title = post['title']
    #     s.detail = date.today()
    #     s.save()
    #     services = Service.objects.all()
    #     print(services)
    #     return render(req, 'myapp/index.html', { 'services': services })
    # else:
    #     print('ร้องขอทำมะดา')
    #     services = Service.objects.all()
    #     print(services)
    #     return render(req, 'myapp/index.html', { 'services': services })
    # if req.method == 'message':
    #     return render(req, 'myapp/message.html')


def base(req):
    return render(req, 'myapp/base.html')

def message(req):
    if req.method == 'POST':
        post = req.POST
        s = Service()
        s.icon = post['icon']
        s.title = post['title']
        s.detail = date.today()
        s.save()
        services = Service.objects.all()
        print(services)
        return render(req, 'myapp/message.html', { 'services': services })
    else:
        print('ร้องขอทำมะดา')
        services = Service.objects.all()
        print(services)
        return render(req, 'myapp/message.html', { 'services': services })
        
