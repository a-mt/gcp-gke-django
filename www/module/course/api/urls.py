from core.routers import SimpleRouter

from .views.course import CourseViewSet


router = SimpleRouter()

router.register(r'', CourseViewSet, basename='course')

urlpatterns = router.urls
