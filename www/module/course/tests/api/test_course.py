from base64 import b64decode
import json
import os

from django.conf import settings
from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import override_settings
from django.urls import reverse

import json
from rest_framework.test import APITestCase

from django.urls import reverse
from module.course.factories.course import CourseFactory


class CourseApiTest(APITestCase):

    def test_list(self):
        """
        Test list courses
        """

        # ---
        # List without any courses: success
        response = self.client.get(
            reverse('api:course:course-list'),
        )
        self.assertEqual(response.status_code, 200)

        # Returns the right payload
        response_payload = json.loads(response.content)
        self.assertEqual(len(response_payload['data']), 0)
        self.assertEqual(response_payload['meta']['pagination']['count'], 0)

        # ---
        # List: success
        CourseFactory()
        CourseFactory()
        CourseFactory(name='API Django')

        response = self.client.get(
            reverse('api:course:course-list'),
        )
        self.assertEqual(response.status_code, 200)

        # Returns the right payload
        response_payload = json.loads(response.content)
        self.assertEqual(len(response_payload['data']), 3)

        # ---
        # Search with one result: success
        response = self.client.get(
            reverse('api:course:course-list') + '?name=django',
        )
        self.assertEqual(response.status_code, 200)

        # Returns the right payload
        response_payload = json.loads(response.content)
        self.assertEqual(len(response_payload['data']), 1)
        self.assertIsNotNone(response_payload['data'][0]['id'])
        self.assertEqual(response_payload['data'][0]['type'], 'course')
        self.assertEqual(response_payload['data'][0]['attributes']['name'], 'API Django')

        # ---
        # Search with no result: success
        response = self.client.get(
            reverse('api:course:course-list') + '?name=NOP',
        )
        self.assertEqual(response.status_code, 200)

        # Returns the right payload
        response_payload = json.loads(response.content)
        self.assertEqual(len(response_payload['data']), 0)

    def test_create(self):
        """
        Test create course
        """

        # ---
        # Create without token: unauthorized
        payload = {
            'name': '',
        }
        response = self.client.post(
            reverse('api:course:course-list'),
            payload,
        )
        self.assertEqual(response.status_code, 401)

        # ---
        # Create with wrong token: unauthorized
        self.client.credentials(HTTP_AUTHORIZATION=f'Token NOP')

        response = self.client.post(
            reverse('api:course:course-list'),
            payload,
        )
        self.assertEqual(response.status_code, 401)

        # ---
        # Create with wrong data: rejected
        self.client.credentials(HTTP_AUTHORIZATION=f'Token {settings.AUTH_API_TOKEN}')

        response = self.client.post(
            reverse('api:course:course-list'),
            payload,
        )
        self.assertEqual(response.status_code, 400)

        # Returns the right payload
        response_payload = json.loads(response.content)
        self.assertEqual(len(response_payload['errors']), 1)

        self.assertEqual(response_payload['errors'][0]['source']['pointer'], '/data/attributes/name')

        # ---
        # Create with correct data: success
        payload['name'] = 'A'

        response = self.client.post(
            reverse('api:course:course-list'),
            payload,
        )
        self.assertEqual(response.status_code, 201)
